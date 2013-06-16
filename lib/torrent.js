var Status = require('./status.js');

module.exports = function Torrent(torrent) {
    this.id = torrent.id;
    this.name = torrent.name;
    this.total_size = torrent.totalSize;
    this.dl_size = torrent.downloadedEver;
    this.dl_rate = torrent.rateDownload;
    this.status = new Status().get[torrent.status];
    this.added_date = torrent.addedDate;
};
