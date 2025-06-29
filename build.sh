rm -rf dist/*

cd keyLog 
gcc main.c -o interface
cp -r interface ../dist/interface
cd .. 

cd exec_inter 
cargo build --release 
cd target/release
cp -r exec_inter ../../../dist/exec
cd ../../../


cd luaSoc
cargo build --release
mkdir -p ../dist/lib/link
cp target/release/libluaSoc.so ../dist/lib/link/luaSoc.so
cd ..

cp -r lib/. dist/lib
