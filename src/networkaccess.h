#ifndef NETWORKACCESS_H
#define NETWORKACCESS_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QSaveFile>
#include <QDir>
#include <QStandardPaths>
#include <QString>
#include <QDebug>

class NetworkAccess : public QNetworkAccessManager {

    Q_OBJECT

public:

    explicit NetworkAccess() { }

    QNetworkAccessManager connectionManager;
    QNetworkRequest request;
    QByteArray responseText;
    QByteArray blankString;
    QNetworkReply* reply;
    QVariant responseCode;
    QString downloadsFolder = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
    QString cacheFolder = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QFile checkFile;
    QSaveFile myFile;
    QDir myDir;

    Q_INVOKABLE void postRequest(QString actionUrl, QByteArray data, QByteArray bearerSessionKey, QString requestType) {

        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);
        reply = connectionManager.post(request, data);

        connect(reply, &QNetworkReply::finished, [=]() {

            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            if (responseCode == 401) responseText = data; // in order to pass the necessary data on to the tokenRefresh function and in turn back to original request type.
            else responseText = reply->readAll();
            finished(responseText, responseCode, requestType);

        });

    }

    Q_INVOKABLE void upload(QString actionUrl, QString localPath, QByteArray serverSidePath, QByteArray bearerSessionKey) {

        QFile currentFile(localPath);

        if (!currentFile.exists()) {

            qInfo() << "Error - File does not exist.";
            responseText = "Error - File does not exist.";
            finished(responseText, 000, "UPLOAD");
            return;

        }

        if (!currentFile.open(QIODevice::ReadOnly)) {

            qInfo() << "Error - Unable to open file.";
            responseText = "Error - Unable to open file.";
            finished(responseText, 000, "UPLOAD");
            return;

        }

        QByteArray dataFile = currentFile.readAll();
        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
        request.setRawHeader("Authorization", bearerSessionKey);
        request.setRawHeader("Dropbox-API-Arg", serverSidePath);
        reply = connectionManager.post(request, dataFile);

        connect(reply, &QNetworkReply::uploadProgress, [=] (qint64 ulProgress, qint64 ulTotal) {

            ulProgressUpdate(ulProgress, ulTotal);

        });

        connect(reply, &QNetworkReply::finished, [=] () {

            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            if (responseCode == 401) responseText = serverSidePath;
            else responseText = reply->readAll();
            finished(responseText, responseCode, "UPLOAD");

        });

    }

    Q_INVOKABLE void largeUpload(QString actionUrl, QString localPath, QByteArray jsonData, QString uploadStage, qint64 uploadOffset, QByteArray bearerSessionKey) {

        QFile currentFile(localPath);

        if (!currentFile.exists()) {

            qInfo() << "Error - File does not exist.";
            responseText = "Error - File does not exist.";
            finished(responseText, 000, uploadStage);
            return;

        }

        if (!currentFile.open(QIODevice::ReadOnly)) {

            qInfo() << "Error - Unable to open file.";
            responseText = "Error - Unable to open file.";
            finished(responseText, 000, uploadStage);
            return;

        }

        if (uploadStage == "UPLOAD_START") { // Upload the first 157286400 B

            QByteArray dataFile = currentFile.read(157286400);
            request.setUrl(actionUrl);
            request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
            request.setRawHeader("Authorization", bearerSessionKey);
            request.setRawHeader("Dropbox-API-Arg", jsonData);
            reply = connectionManager.post(request, dataFile);

            connect(reply, &QNetworkReply::uploadProgress, [=] (qint64 ulProgress, qint64 ulTotal) {

                ulProgressUpdate(ulProgress, ulTotal);

            });

            connect(reply, &QNetworkReply::finished, [=] () {

                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                if (responseCode == 401) responseText = jsonData;
                else responseText = reply->readAll();
                finished(responseText, responseCode, "UPLOAD_START");

            });

        }

        else if (uploadStage == "FINISH") {

            if (currentFile.seek(uploadOffset)) {

                QByteArray dataFile = currentFile.readAll(); // rest of file
                request.setUrl(actionUrl);
                request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
                request.setRawHeader("Authorization", bearerSessionKey);
                request.setRawHeader("Dropbox-API-Arg", jsonData);
                reply = connectionManager.post(request, dataFile);

                connect(reply, &QNetworkReply::uploadProgress, [=] (qint64 ulProgress, qint64 ulTotal) {

                    ulProgressUpdate(ulProgress, ulTotal);

                });

                connect(reply, &QNetworkReply::finished, [=] () {

                    responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                    if (responseCode == 401) responseText = jsonData;
                    else responseText = reply->readAll();
                    finished(responseText, responseCode, "FINISH");

                });

            }

            else {

                qInfo() << "Error - Unable to seek to a new position in the file.";
                responseText = "Error - Unable to seek to a new position in the file.";
                finished(responseText, 000, "FINISH");

            }

        }

        else { // In progress

            if (currentFile.seek(uploadOffset)) {

                QByteArray dataFile = currentFile.read(157286400); // should be from the offset point onward.

                request.setUrl(actionUrl);
                request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
                request.setRawHeader("Authorization", bearerSessionKey);
                request.setRawHeader("Dropbox-API-Arg", jsonData);
                reply = connectionManager.post(request, dataFile);

                connect(reply, &QNetworkReply::uploadProgress, [=] (qint64 ulProgress, qint64 ulTotal) {

                    ulProgressUpdate(ulProgress, ulTotal);

                });

                connect(reply, &QNetworkReply::finished, [=] () {

                    responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                    if (responseCode == 401) responseText = jsonData;
                    else responseText = reply->readAll();
                    finished(responseText, responseCode, "IN_PROGRESS");

                });

            }

            else {

                qInfo() << "Error - Unable to seek to a new position in the file.";
                responseText = "Error - Unable to seek to a new position in the file.";
                finished(responseText, 000, "IN_PROGRESS");

            }

        }

    }

    Q_INVOKABLE void downloadThumbnail(QString actionUrl, QByteArray filepath, QString saveFileAs, QByteArray bearerSessionKey) {

        myFile.setFileName(cacheFolder + "/" + saveFileAs);
        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");
        request.setRawHeader("Authorization", bearerSessionKey);
        request.setRawHeader("Dropbox-API-Arg", filepath);
        blankString = ""; // not sure why this was needed..
        reply = connectionManager.post(request, blankString); // ..likely this wasn't working without it

        connect(reply, &QNetworkReply::finished, [=]() {

            if (reply->error() == QNetworkReply::NoError) {

                QSaveFile myFile(cacheFolder + "/" + saveFileAs);

                if (myFile.open(QIODevice::WriteOnly)) qInfo() << "Attempt to open myFile succeeded.";

                else {

                    qInfo() << "Attempt to open myFile failed.";
                    return;

                }

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                if (myFile.write(responseText) == -1) qInfo() << "Error writing to file.";
                else qInfo() << "Wrote to file successfully.";
                qInfo() << "Committing changes...";

                if (myFile.commit()) {

                    qInfo() << "Attempt to commit myFile succeeded.";
                    finished("Not including responseText, file data is separate.", responseCode, cacheFolder + "/" + saveFileAs);

                }

                else {

                    responseCode = 999;
                    qInfo() << "Attempt to commit myFile failed.";
                    finished("Error saving thumbnail to disk.", responseCode, "THUMBNAIL");

                }

            }

            else {

                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                responseText = reply->readAll();
                if (responseCode == 401) finished(filepath, responseCode, "THUMBNAIL");
                else finished(responseText, responseCode, "THUMBNAIL");

            }

        });

    }

    Q_INVOKABLE void downloadFile(QString actionUrl, QByteArray filePath, QByteArray saveFileAs, QByteArray bearerSessionKey, QString downloadDestination) {

        myFile.setFileName(downloadDestination + "/" + saveFileAs);
        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");
        request.setRawHeader("Authorization", bearerSessionKey);
        request.setRawHeader("Dropbox-API-Arg", filePath);
        blankString = "";
        reply = connectionManager.post(request, blankString);

        connect(reply, &QNetworkReply::downloadProgress, [=](qint64 dlProgress, qint64 dlTotal) {

            dlProgressUpdate(dlProgress, dlTotal);

        });

        connect(reply, &QNetworkReply::finished, [=]() {

            if (reply->error() == QNetworkReply::NoError) {

                QSaveFile myFile(downloadDestination + "/" + saveFileAs);

                if (myFile.open(QIODevice::WriteOnly)) qInfo() << "Attempt to open myFile succeeded.";

                else {

                    qInfo() << "Attempt to open myFile failed.";
                    qInfo() << "Download destination:";
                    qInfo() << downloadDestination;
                    return;

                }

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                if (myFile.write(responseText) == -1) qInfo() << "Error writing to file.";
                else qInfo() << "Wrote to file successfully.";
                qInfo() << "Committing changes...";

                if (myFile.commit()) {

                    qInfo() << "Attempt to commit myFile succeeded.";
                    finished("Not including responseText as file data is separate.", responseCode, "FILE_DOWNLOAD");

                }

                else {

                    responseCode = 999;
                    qInfo() << "Attempt to commit myFile failed.";
                    finished("Error saving file to disk", responseCode, "FILE_DOWNLOAD");

                }

            }

            else { // handle error

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode, "FILE_DOWNLOAD");

            }

        });

    }

    Q_INVOKABLE bool fileAlreadyExists(QString fileUrl) {

        checkFile.setFileName(fileUrl);
        return checkFile.exists();

    }

    Q_INVOKABLE bool directoryExists(QString path) {

        if (myDir.cd(path)) return myDir.exists();
        else return false;

    }

    Q_INVOKABLE QString getDlFolderPath() {

        return downloadsFolder; // QML StandardPaths type only for Qt 6.2 onward -- for now using this method.

    }

    Q_INVOKABLE qint64 getFileSize(QString fileUrl) {

        QFile whatSizeAmI(fileUrl);
        return whatSizeAmI.size();

    }

    Q_INVOKABLE void tokenRefresh(QString origRequestType, QString url, QByteArray origData, QString origSupplemental) {

        request.setUrl(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Accept", "application/json");
        reply = connectionManager.get(request);

        connect(reply, &QNetworkReply::finished, [=]() {

            responseText = reply->readAll();
            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            refreshFinished(responseText, responseCode, origRequestType, origData, origSupplemental);

        });

    }

signals:

    void finished(QByteArray responseText, QVariant responseCode, QString requestType);
    void refreshFinished(QByteArray responseText, QVariant responseCode, QString origRequestType, QByteArray origData, QString origSupplemental);
    void dlProgressUpdate(qint64 dlProgress, qint64 dlTotal);
    void ulProgressUpdate(qint64 ulProgress, qint64 ulTotal);

};

#endif // NETWORKACCESS_H
