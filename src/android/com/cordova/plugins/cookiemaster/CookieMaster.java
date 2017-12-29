package com.cordova.plugins.cookiemaster;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

import java.net.HttpCookie;

import android.webkit.CookieManager;

public class CookieMaster extends CordovaPlugin {

    private final String TAG = "CookieMasterPlugin";
    public static final String ACTION_GET_COOKIE_VALUE = "getCookieValue";
    public static final String ACTION_SET_COOKIE_VALUE = "setCookieValue";
    public static final String ACTION_CLEAR_COOKIES = "clearCookies";

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (ACTION_GET_COOKIE_VALUE.equals(action)) {
            final String url = args.getString(0);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        CookieManager cookieManager = CookieManager.getInstance();
                        String[] cookies = cookieManager.getCookie(url).split("; ");
                        String cookieValue = "";
						String cCookieName = "";
						JSONArray jsonArray = new JSONArray();
						JSONObject json = null;
						for (int i = 0; i < cookies.length; i++) {
							json = new JSONObject();
                            cCookieName = cookies[i].split("=")[0].trim();
							cookieValue = cookies[i].split("=")[1].trim();
							json.put("key", cCookieName);
							json.put("value", cookieValue);
							jsonArray.put(json);
                        }
                        if (jsonArray != null) {
                            PluginResult res = new PluginResult(PluginResult.Status.OK, jsonArray);
                            callbackContext.sendPluginResult(res);
                        } else {
                            callbackContext.error("Cookie not found!");
                        }
                    } catch (Exception e) {
                        Log.e(TAG, "Exception: " + e.getMessage());
                        callbackContext.error(e.getMessage());
                    }
                }
            });
            return true;

        } else if (ACTION_SET_COOKIE_VALUE.equals(action)) {
            final String url = args.getString(0);
            final String cookieName = args.getString(1);
            final String cookieValue = args.getString(2);

            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    try {
                        HttpCookie cookie = new HttpCookie(cookieName, cookieValue);

                        String cookieString = cookie.toString().replace("\"", "");
                        CookieManager cookieManager = CookieManager.getInstance();
                        cookieManager.setCookie(url, cookieString);

                        PluginResult res = new PluginResult(PluginResult.Status.OK, "Successfully added cookie");
                        callbackContext.sendPluginResult(res);
                    } catch (Exception e) {
                        Log.e(TAG, "Exception: " + e.getMessage());
                        callbackContext.error(e.getMessage());
                    }
                }
            });
            return true;
        }

        else if (ACTION_CLEAR_COOKIES.equals(action)) {

            CookieManager cookieManager = CookieManager.getInstance();

            /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
			    cookieManager.removeAllCookies();
			    cookieManager.flush();
			} else
			{
			    cookieManager.removeAllCookie();
			    cookieManager.removeSessionCookie();
			}*/

			callbackContext.success();
            return true;
        }

        callbackContext.error("Invalid action");
        return false;

    }
}
