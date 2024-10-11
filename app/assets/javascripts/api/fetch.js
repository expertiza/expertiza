function fetchJSONData(request) { //rename to fetchJSONData
    return new Promise((resolve, reject) => {
        fetch(request.url, {
            method: request.method,
            headers: request.headers,
            body: request.body,
        }).then(function (response) {
            resolve(response.json());
        }).catch((e) => {
            reject("Error while fetching data - ", e);
        });
    });
}