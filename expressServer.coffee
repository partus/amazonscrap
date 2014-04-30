lg = ->
  console.log.apply console, arguments
  return
fs = require("fs")
sys = require 'sys'
exec = require('child_process').exec
redis = {}
if (process.env.REDISTOGO_URL) 
 	   
else 
	redis = require("redis").createClient();
redis.on "error", (err) ->
  console.log "Error " + err
  return


execPuts = (cmd, done) ->
  console.log 'Executing', cmd
  exec cmd, (error, stdout, stderr) ->
    sys.puts stderr
    #sys.puts stdout
    done()


express = require('express');
app = express();
app.use(require("body-parser")({limit: "5mb"}));
app.get "/hello.txt", (req, res) ->
  res.send "Hello World"
  return
app.post "/", (req,res)->
	# lg req.body
	# lg typeof req.body
	redis.set "dump", JSON.stringify req.body
	res.send("ok")
app.get "/", (req,res)->
  redis.get "dump", (err,reply)->
    if err
      res.statusCode=404
      res.send err
      return null
    all = if reply then JSON.parse reply else {}
    str=all.all or "{}"
    res.send JSON.parse(str) 


server = app.listen(process.env.PORT or 5000, ->
  console.log "Listening on port %d", server.address().port
  return
)


execPuts "casperjs amazonCasper.coffee", ->
	lg "casper done"

