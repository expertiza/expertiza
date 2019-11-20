function toggleFunction(elementId) {
    var target = document.getElementById(elementId);
    if (target.style.display === 'none') {
        target.style.display = 'block';
    } else {
        target.style.display = 'none';
    }
}


