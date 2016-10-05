/*global cordova, module*/

module.exports = {
    /**
     * Send request to Auto video player.
     *
     * @param {String} url       media file url
     * @param {String} volume    volume
     * @param {String} scale     Player Frame type
     */
    autoplay: function (data, successCallback) {
            var sendData = {};
            if(!data.url) return;
            sendData.url = (data.url||'');
            sendData.volume = (data.volume||100);
            sendData.scale = (data.scale||true);
            var senddata = JSON.stringify(sendData);
            cordova.exec(successCallback, null, "AutoVideoPlay", "autoplay", [senddata]);
    }
};
