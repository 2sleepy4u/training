build:
	echo "Building project..."
	echo "Starting with Elm Frontend..."
	cd elm
	elm make src/Main.elm --output=./../rustyserver/pages/app/main.js
	elm make src/Login.elm --output=./../rustyserver/pages/login/login.js
	echo "Elm frontend built."
	cd ..
	echo "Starting with rust webserver"
	cd rustyserver
	cargo build
	echo "Rust webserver built."
	cd ..

run: build
	cd rustyserver
	cargo run 

