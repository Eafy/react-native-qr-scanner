package com.eafy.react_native_qr_scanner;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Callback;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;
import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;

public class RCTQRScannerViewManager extends ViewGroupManager<DecoratedBarcodeView> implements DecoratedBarcodeView.TorchListener, ActivityEventListener {

    private Context mContent;
    private DecoratedBarcodeView barcodeScannerView;
    private CaptureManager capture;
    private Callback mCallback;

    @Override
    public String getName() {
        return "QRScannerView";
    }

    @Override
    protected DecoratedBarcodeView createViewInstance(ThemedReactContext reactContext) {
        mContent = reactContext;

        barcodeScannerView = new DecoratedBarcodeView(reactContext);
        barcodeScannerView.setTorchListener(this);

        capture = new CaptureManager(null, barcodeScannerView);
//        capture.initializeFromIntent(null, this);
        capture.decode();

        return barcodeScannerView;
    }

    @Override
    public void onTorchOn() {

    }

    @Override
    public void onTorchOff() {

    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        IntentResult result = IntentIntegrator.parseActivityResult(resultCode, data);
        mCallback.invoke(result.getContents());
    }

    @Override
    public void onNewIntent(Intent intent) {}
}
