/**
 * WindowManager class.
 *
 * The WindowManager has been added to DRY up
 * logic for managing windows in a stack/queue.
 */
function WindowManager() {
    this.windows = [];
}

/**
 * Add [window] to the managed window queue as long
 * as it is not null.
 * @param window
 */
WindowManager.prototype.manage = function(window) {
    if (window) {
        this.windows.push(window);
    }
};

/**
 * Closes all windows being managed by the manager,
 * and empties the queue.
 */
WindowManager.prototype.closeAll = function() {
    while (this.windows.length) {
        this.windows.shift().close();
    }
};

/**
 * @returns {number} The number of windows in the queue
 */
WindowManager.prototype.size = function() {
    return this.windows.length;
};
