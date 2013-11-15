      package plugin.google.maps;

import java.lang.reflect.Method;
import java.util.HashMap;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.annotation.SuppressLint;
import android.graphics.Color;
import android.util.Log;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.PolygonOptions;

public class PluginPolygon extends CordovaPlugin implements MyPlugin  {
  private final String TAG = "PluginPolygon";
  public GoogleMap map = null;
  private HashMap<String, Polygon> polygons;

  @SuppressLint("UseSparseArrays")
  @Override
  public void initialize(CordovaInterface cordova, final CordovaWebView webView) {
    Log.d(TAG, "Polygon class initializing");
    this.polygons = new HashMap<String, Polygon>();
  }
  @Override
  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    String[] params = args.getString(0).split("\\.");
    try {
      Method method = this.getClass().getDeclaredMethod(params[1], JSONArray.class, CallbackContext.class);
      method.invoke(this, args, callbackContext);
      return true;
    } catch (Exception e) {
      e.printStackTrace();
      callbackContext.error(e.getMessage());
      return false;
    }
  }

  public void setMap(GoogleMap map) {
    this.map = map;
  }
  

  /**
   * Create polygon
   * @param args
   * @param callbackContext
   * @throws JSONException 
   */
  @SuppressWarnings("unused")
  private void createPolygon(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    final PolygonOptions polygonOptions = new PolygonOptions();
    int color;
    
    JSONObject opts = args.getJSONObject(1);
    if (opts.has("points")) {
      JSONArray points = opts.getJSONArray("points");
      LatLng[] path = new LatLng[points.length()];
      JSONObject pointJSON;
      int i = 0;
      for (i = 0; i < points.length(); i++) {
        pointJSON = points.getJSONObject(i);
        path[i] = new LatLng(pointJSON.getDouble("lat"), pointJSON.getDouble("lng"));
      }
      polygonOptions.add(path);
    }
    if (opts.has("strokeColor")) {
      color = GoogleMaps.parsePluginColor(opts.getJSONArray("strokeColor"));
      polygonOptions.strokeColor(color);
    }
    if (opts.has("fillColor")) {
      color = GoogleMaps.parsePluginColor(opts.getJSONArray("fillColor"));
      polygonOptions.fillColor(color);
    }
    if (opts.has("strokeWidth")) {
      polygonOptions.strokeWidth(opts.getInt("strokeWidth"));
    }
    if (opts.has("visible")) {
      polygonOptions.visible(opts.getBoolean("visible"));
    }
    if (opts.has("geodesic")) {
      polygonOptions.geodesic(opts.getBoolean("geodesic"));
    }
    if (opts.has("zIndex")) {
      polygonOptions.zIndex(opts.getInt("zIndex"));
    }
    
    Polygon polygon = map.addPolygon(polygonOptions);
    this.polygons.put(polygon.getId(), polygon);
    callbackContext.success(polygon.getId());
  }
  

  /**
   * set fill color
   * @param args
   * @param callbackContext
   * @throws JSONException
   */
  @SuppressWarnings("unused")
  private void setFillColor(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String id = args.getString(1);
    int color = GoogleMaps.parsePluginColor(args.getJSONArray(2));
    Polygon polygon = this.polygons.get(id);
    polygon.setFillColor(color);
    callbackContext.success();
  }
  
  /**
   * set stroke color
   * @param args
   * @param callbackContext
   * @throws JSONException
   */
  @SuppressWarnings("unused")
  private void setStrokeColor(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String id = args.getString(1);
    int color = Color.parseColor(args.getString(2));
    Polygon polygon = this.polygons.get(id);
    polygon.setStrokeColor(color);
    callbackContext.success();
  }
  
  /**
   * set stroke width
   * @param args
   * @param callbackContext
   * @throws JSONException
   */
  @SuppressWarnings("unused")
  private void setStrokeWidth(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String id = args.getString(1);
    float width = (float) args.getDouble(2);
    Polygon polygon = this.polygons.get(id);
    polygon.setStrokeWidth(width);
    callbackContext.success();
  }
  
  /**
   * set z-index
   * @param args
   * @param callbackContext
   * @throws JSONException
   */
  @SuppressWarnings("unused")
  private void setZIndex(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String id = args.getString(1);
    float zIndex = (float) args.getDouble(2);
    Polygon polygon = this.polygons.get(id);
    polygon.setZIndex(zIndex);
    callbackContext.success();
  }
  
  /**
   * set visibility
   * @param args
   * @param callbackContext
   * @throws JSONException
   */
  @SuppressWarnings("unused")
  private void setVisible(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String id = args.getString(1);
    boolean visible = args.getBoolean(2);
    Polygon polygon = this.polygons.get(id);
    polygon.setVisible(visible);
    callbackContext.success();
  }

  /**
   * Remove the polygon
   * @param args
   * @param callbackContext
   * @throws JSONException
   */
  @SuppressWarnings("unused")
  private void remove(final JSONArray args, final CallbackContext callbackContext) throws JSONException {
    String id = args.getString(1);
    Polygon polygon = this.polygons.get(id);
    this.polygons.remove(id);
    polygon.remove();
    callbackContext.success();
  }
}
