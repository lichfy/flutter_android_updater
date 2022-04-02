
abstract class OnDownloadListener {
   void onStart([bool force = false]);

   void onProgress(int receivedBytes, int totalBytes);

   void onFinish();
 }