class Metric {
//    Keep track of the URL of interest
    URL = null;
    displayName = null;
    toolTipText = null;
// //    Call API with given input
// //      Format API response and return
    constructor(myUrl, displayName, toolTipText) {
        this.URL = myUrl;
        this.displayName = displayName;
        this.toolTipText = toolTipText;
        if(this.constructor == Metric) {
            throw new Error("Abstract classes can't be instantiated.");
        }
    }

    //This function makes POST API call to the given url with final_json data
    makeRequest(final_json)
    {
        return new Promise(function (resolve, reject)
        {
            let xhr = new XMLHttpRequest();
            xhr.open('POST', this.URL);
            xhr.setRequestHeader('content-type', 'application/json');
            xhr.onload = function ()
            {
                if (this.status >= 200 && this.status < 300)
                {
                    resolve(xhr.response);
                }
                else
                {
                    let reason = {
                        status: this.status,
                        statusText: xhr.statusText
                    };
                    reject(
                        new Error(JSON.stringify(reason))
                    );
                }
            };
            xhr.onerror = function ()
            {
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

    callAPI(input) {
        throw new Error("Method 'callAPI()' must be implemented.");
    }
}