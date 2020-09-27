function ep
  ssh -R sfr.eu.ngrok.io:0:localhost:$argv tunnel.eu.ngrok.com http
end
