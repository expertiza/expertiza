function getSubFolderResults(params) {
    var request = {
        method: 'POST',
        url: '/tree_display/get_sub_folder_contents',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        },
        body: serialize({
            reactParams2: params
        })
    }
    return fetchJSONData(request);
}

function getFolderResults() {
    var request = {
        method: 'GET',
        url: '/tree_display/get_folder_contents',
        headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
    }
    return fetchJSONData(request);
}

function setSessionLastOpenTab(queryParams) {
    var request = {
        method: 'GET',
        url: '/tree_display/set_session_last_open_tab?tab=' + queryParams.toString(),
        headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
    }
    return fetchJSONData(request);
}

function getSessionLastOpenTab() {
    var request = {
        method: 'GET',
        url: '/tree_display/session_last_open_tab',
        headers: {
            "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
    }
    return fetchJSONData(request);
}

function serialize(obj, prefix) {
    var str = [],
        p;
    for (p in obj) {
        if (obj.hasOwnProperty(p)) {
            var k = prefix ? prefix + "[" + p + "]" : p,
                v = obj[p];
            str.push((v !== null && typeof v === "object") ?
                serialize(v, k) :
                encodeURIComponent(k) + "=" + encodeURIComponent(v));
        }
    }
    return str.join("&");
}