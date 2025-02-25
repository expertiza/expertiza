/* 
A load balancer and blue-green deployment implementation of Expertiza which are running on two port, 3000 and 3001.
Handle all incoming requests on port 8080.
The ansible script runs this file.
*/

var http = require('http');
var httpProxy = require('http-proxy')
var proxy = httpProxy.createProxyServer({});

var server=http.createServer( function (req, res){
	
	/* 
	Math.random() is used to randomly generate a new number since we 
	only want 20% of all requests to be redirected to the green channel on port 3001.
	*/

	var random = Math.random()
	
	/* 
	The 0.8 figure is used to route 20% of all requests to be redirected to the green channel on port 3001.
	*/

	if(random<=0.8) {

		/* 
		Redirect to port 3000. If an error occus then redirect to port 3001.
		*/

		proxy.web(req, res, {target: "http://localhost:3000"}, function (e){
                	proxy.web(req, res, {target: "http://localhost:3001"});
        	});
	}
	else {

		/* 
		Redirect to port 3001. If an error occus then redirect to port 3000.
		*/

		proxy.web(req, res, {target: "http://localhost:3001"}, function (e){
		    proxy.web(req, res, {target: "http://localhost:3000"});
		});
    	}
});

/* 
Serve all incoming requests on port 8080.
*/

server.listen(8080);