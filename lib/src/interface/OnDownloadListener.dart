
 abstract class OnDownloadListener {
   void onStart();

   void onProgress(int receivedBytes, int totalBytes);

   void onFinish();
 }