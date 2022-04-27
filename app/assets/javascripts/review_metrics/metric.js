// Base Metric Class to call the correspondoing API and return the formated respose accordingly

class Metric {

    // Definining the constructor
    constructor(URL) {
        this.URL = URL;
        if (this.constructor == Metric) {
            throw new Error("Abstract classes can't be instantiated.");
        }
    }

    // This function is used to call the API and return the response
    async call_API(input) {

        try {
            let response = await this.makeRequest(input);
            return JSON.parse(response);
        }
        catch (error) {
            throw error;
        }
    }

    //This function makes POST API call to the given url with final_json data
    makeRequest(final_json) {
        let myURL = this.URL;
        return new Promise(function (resolve, reject) {
            let xhr = new XMLHttpRequest();
            xhr.open('POST', myURL);
            xhr.setRequestHeader('content-type', 'application/json');
            xhr.onload = function () {
                if (this.status >= 200 && this.status < 300) {
                    resolve(xhr.response);
                }
                else {
                    let reason = {
                        status: this.status,
                        statusText: xhr.statusText //Checking the status for API
                    };
                    reject(
                        new Error(JSON.stringify(reason)) // Checking for Errors while loading API
                    );
                }
            };
            xhr.onerror = function () {
                let reason = {
                    status: this.status,
                    statusText: xhr.statusText // Checking for status of API
                };
                reject(
                    new Error(JSON.stringify(reason)) // Checking for Errors why API is not loading
                );
            };
            xhr.send(final_json);
        });
    }

    // This function is used to get the response from the API and format it accordingly
    format_response(response, analysis) {
        throw new Error("Method 'formatResponse()' must be implemented.");
    }
}