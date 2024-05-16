//go:build wasm
// +build wasm

package main

import (
	"log"
	"net/http"
	"syscall/js"

	"github.com/maxence-charriere/go-app/v9/pkg/app"
)

func sendData(this js.Value, inputs []js.Value) interface{} {
	input := inputs[0].String()
	// Process the input, for example, just echo it back for now
	js.Global().Call("displayInTerminal", "Received: "+input)
	return nil
}

func main() {
	// Register the function with JS
	js.Global().Set("send_data", js.FuncOf(sendData))

	// HTTP routing:
	http.Handle("/", &app.Handler{
		Name:        "DROO.foo",
		Description: "The future belongs to those who believe in the beauty of their dreams.",
	})

	if err := http.ListenAndServe(":8000", nil); err != nil {
		log.Fatal(err)
	}
}
