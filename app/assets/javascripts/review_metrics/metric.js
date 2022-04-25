class Metric {
    constructor(URL) {
        this.URL = URL;
        if (this.constructor == Metric) {
            throw new Error("Abstract classes can't be instantiated.");
        }
    }

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
                        statusText: xhr.statusText
                    };
                    reject(
                        new Error(JSON.stringify(reason))
                    );
                }
            };
            xhr.onerror = function () {
                let reason = {
                    status: this.status,
                    statusText: xhr.statusText
                };
                reject(
                    new Error(JSON.stringify(reason))
                );
            };
            xhr.send(final_json);
        });
    }

    // callAPI(input) {
    //     throw new Error("Method 'callAPI()' must be implemented.");
    // }

    format_response(response, analysis) {
        throw new Error("Method 'formatResponse()' must be implemented.");
    }
}