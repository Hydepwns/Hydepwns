//go:build wasm
// +build wasm

package main

import (
	"fmt"
	"log"
	"net/http"
	"syscall/js"

	"github.com/maxence-charriere/go-app/v9/pkg/app"
)

type hello struct {
	app.Compo

	name string
}

func (h *hello) Render() app.UI {
	// Instead of returning UI directly, send output to JavaScript
	js.Global().Call("displayInTerminal", fmt.Sprintf("Hello, %s!", h.name))
	return nil // Return nil if you handle rendering through JavaScript
}

func main() {
	// Components routing:
	app.Route("/", &hello{})
	app.Route("/hello", &hello{})
	app.RunWhenOnBrowser()

	// HTTP routing:
	http.Handle("/", &app.Handler{
		Name:        "DROO.foo",
		Description: "The future belongs to those who believe in the beauty of their dreams.",
	})

	if err := http.ListenAndServe(":8000", nil); err != nil {
		log.Fatal(err)
	}
}
