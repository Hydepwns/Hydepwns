build-wasm:
	GOARCH=wasm GOOS=js go build -o web/app.wasm .

build-native:
	go build -o drooFoo .

build: build-wasm build-native

run: build
	./drooFoo
