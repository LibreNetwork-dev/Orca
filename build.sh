rm -rf dist/*

cd luaSoc
cargo build --release
mkdir -p ../dist/lib/link
cp target/release/libluaSoc.so ../dist/lib/link/luaSoc.so
cd ..

cp -r lib/. dist/lib
cp -r assets/ dist/assets

cd inter
cargo build --release 
cd target/release
cp orca_interface ../../../dist/orca
