module.exports = function Status() {
    this.get = [
        "STOPPED",
        "CHECK_WAIT",
        "CHECK",
        "DOWNLOAD_WAIT",
        "DOWNLOAD",
        "SEED_WAIT",
        "SEED",
        "ISOLATED"
    ]; 
}
