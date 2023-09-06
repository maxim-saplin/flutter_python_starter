kill -9 $(lsof -ti:50055,8080)
echo "Statring Python server"
python3 ../server/server.py & 
sleep 1
echo "Statring Web Proxy"
../grpcwebproxy-v0.15.0-osx-x86_64 --backend_addr=localhost:50055 --run_tls_server=false --allow_all_origins &