Run storage_servers1, 2, and 3, and directory_server.
Directory server handles directory and locking services and keeps track of storage replication.
Servers 1, 2 and 3 run on ports 8001, 8002 and 8003 respectively, (hardcoded) Should modify to dynamically assign ports?

Client interacts with file server using the client_proxy.
Can use 'open', 'close' and 'list' commands to pull down and push files as well as list available files.
Requested files are pulled down to local folder 'Client', modified locally and can then be pushed.