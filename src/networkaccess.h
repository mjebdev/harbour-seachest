#ifndef NETWORKACCESS_H
#define NETWORKACCESS_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QSaveFile>
#include <QStandardPaths>
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

    Q_INVOKABLE void listFolderContents(QString actionUrl, QByteArray folderPath, QByteArray bearerSessionKey) {

        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        //request.setRawHeader("Accept", "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);
        //request.setRawHeader("Dropbox-API-Arg", filePath);
        reply = connectionManager.post(request, folderPath);

        connect(reply, &QNetworkReply::finished, [=]() {

            //if (reply->error() == QNetworkReply::NoError) {

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode, "LIST_FOLDER");

            //}

            //else { // handle error

                //responseText = reply->readAll();
                //responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                //finished(responseText, responseCode, "POST");

            //}

        });

    }

    Q_INVOKABLE void downloadThumbnail(QString actionUrl, QByteArray filepath, QByteArray saveFileAs, QByteArray bearerSessionKey) {

        myFile.setFileName(cacheFolder + "/" + saveFileAs);
        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");
        request.setRawHeader("Authorization", bearerSessionKey);
        request.setRawHeader("Dropbox-API-Arg", filepath);
        blankString = "";
        reply = connectionManager.post(request, blankString);

        connect(reply, &QNetworkReply::finished, [=]() {

            if (reply->error() == QNetworkReply::NoError) {

                const QString cacheFolder = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
                QSaveFile myFile(cacheFolder + "/" + saveFileAs);

                if (myFile.open(QIODevice::WriteOnly)) {

                    qInfo() << "Attempt to open myFile succeeded.";

                }

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

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode, "THUMBNAIL");

            }

        });

    }

    Q_INVOKABLE void downloadFile(QString actionUrl, QByteArray filePath, QByteArray saveFileAs, QByteArray bearerSessionKey) {

        myFile.setFileName(downloadsFolder + "/" + saveFileAs);
        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "text/plain");
        //request.setRawHeader("Accept", "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);
        request.setRawHeader("Dropbox-API-Arg", filePath);
        blankString = "";
        reply = connectionManager.post(request, blankString);

        connect(reply, &QNetworkReply::downloadProgress, [=](qint64 dlProgress, qint64 dlTotal) {

            dlProgressUpdate(dlProgress, dlTotal);
            //qInfo("Progress stats: ");
            //qInfo() << dlProgress;
            //qInfo() << dlTotal;
            //qInfo() << "--progress stats end.";

        });

        connect(reply, &QNetworkReply::finished, [=]() {

            if (reply->error() == QNetworkReply::NoError) {

                const QString downloadsFolder = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
                QSaveFile myFile(downloadsFolder + "/" + saveFileAs);

                if (myFile.open(QIODevice::WriteOnly)) qInfo() << "Attempt to open myFile succeeded.";

                else {

                    qInfo() << "Attempt to open myFile failed.";
                    return;

                }

                // no error -- manage file just downloaded
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

    Q_INVOKABLE void get(QString url, QByteArray bearerSessionKey, QString requestType) {

        request.setUrl(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Accept", "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);
        reply = connectionManager.get(request);

        connect(reply, &QNetworkReply::finished, [=]() {

            if (reply->error() == QNetworkReply::NoError) {

                responseText = reply->readAll();
                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode, requestType);

            }

            else { // handle error

                responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
                finished(responseText, responseCode, requestType);

            }

        });

    }

    Q_INVOKABLE bool fileAlreadyExists(QString partialFileUrl) {

        // need to change to passing the entire URL
        // determine folder location on QML side
        // will allow for easier customization later by User i.e. using Documents instead, or another specified folder.

        //const QString downloadsFolder = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
        //QFile myFile(downloadsFolder + "/" + partialFileUrl);

        checkFile.setFileName(downloadsFolder + "/" + partialFileUrl);
        //if (myFile.exists()) return true;
        //else return false;
        return checkFile.exists();

    }

    Q_INVOKABLE void folderRefresh(QString url) {

        request.setUrl(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Accept", "application/json");

        reply = connectionManager.get(request);

        connect(reply, &QNetworkReply::finished, [=]() {

            responseText = reply->readAll();
            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            finished(responseText, responseCode, "TOKEN_REFRESH");

        });

    }

    Q_INVOKABLE void transferRefresh(QString requestType, QString url, QString localFolder, QString newFile) {

        request.setUrl(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Accept", "application/json");

        reply = connectionManager.get(request);

        connect(reply, &QNetworkReply::finished, [=]() {

            responseText = reply->readAll();
            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            refreshFinished(responseText, responseCode, requestType, localFolder, newFile);

        });

    }

    Q_INVOKABLE void tokenRefresh(QString origRequestType, QString url, QString fieldOne, QString fieldTwo) {

        // will try to move all token-refresh requests to this for simplification..
        request.setUrl(url);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        request.setRawHeader("Accept", "application/json");

        reply = connectionManager.get(request);

        connect(reply, &QNetworkReply::finished, [=]() {

            responseText = reply->readAll();
            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            refreshFinished(responseText, responseCode, origRequestType, fieldOne, fieldTwo); // doubtful three are needed; barely need two.

        });

    }

    Q_INVOKABLE void upload(QString actionUrl, QString localPath, QByteArray serverSidePath, QByteArray bearerSessionKey) {

        QFile currentFile(localPath);

        if (!currentFile.exists()) {

            qInfo() << "Error - File does not exist.";
            responseText = "Error - File does not exist.";
            finished(responseText, 000, "UPLOADED_FILE");
            return;

        }

        if (!currentFile.open(QIODevice::ReadOnly)) {

            qInfo() << "Error - Unable to open file.";
            responseText = "Error - Unable to open file.";
            finished(responseText, 000, "UPLOADED_FILE");
            return;

        }

        QByteArray dataFile = currentFile.readAll();
        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/octet-stream");
        //request.setRawHeader("Accept", "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);
        request.setRawHeader("Dropbox-API-Arg", serverSidePath);

        reply = connectionManager.post(request, dataFile);

        connect(reply, &QNetworkReply::uploadProgress, [=] (qint64 ulProgress, qint64 ulTotal) {

            ulProgressUpdate(ulProgress, ulTotal);

        });

        connect(reply, &QNetworkReply::finished, [=] () {

            responseText = reply->readAll();
            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            finished(responseText, responseCode, "UPLOADED_FILE");

        });

    }

    Q_INVOKABLE void renameOrDelete(QString actionUrl, QByteArray data, QByteArray bearerSessionKey, QString requestType) {

        request.setUrl(actionUrl);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        //request.setRawHeader("Accept", "application/json");
        request.setRawHeader("Authorization", bearerSessionKey);
        //request.setRawHeader("Dropbox-API-Arg", filePath);
        reply = connectionManager.post(request, data);

        connect(reply, &QNetworkReply::finished, [=]() {

            responseCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute);
            if (responseCode == 401) responseText = data; // in order to pass the necessary data on through the refresh-token process.
            else responseText = reply->readAll();
            finished(responseText, responseCode, requestType); // responseText needs to be the data, or url for GET requests, if a refreshed token is needed.

        });

    }

signals:

    void finished(QByteArray responseText, QVariant responseCode, QString requestType);

    void refreshFinished(QByteArray responseText, QVariant responseCode, QString origRequestType, QString fieldOne, QString fieldTwo);

    void dlProgressUpdate(qint64 dlProgress, qint64 dlTotal);

    void ulProgressUpdate(qint64 ulProgress, qint64 ulTotal);

};

#endif // NETWORKACCESS_H
