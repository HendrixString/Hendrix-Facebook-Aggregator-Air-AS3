package com.hendrix.facebook.commands
{
  import flash.events.Event;
  import flash.net.URLRequestMethod;
  import flash.utils.ByteArray;
  
  import com.hendrix.facebook.co.uk.mikestead.net.URLFileVariable;
  import com.hendrix.facebook.co.uk.mikestead.net.URLRequestBuilder;
  import com.hendrix.facebook.core.GraphRequest;
  
  /**
   * Facebook photo poster<br>
   * <b>Notes:</b>
   * <li>use <code>this.imgBinray</code> to set a compressed binary image</li>
   * <li>use <code>this.imgMessage</code> to set a cation to the posted image</li>
   * <li>this class is optimized for memory and promotes reusing. objects are instantiated once</li>
   * @author Tomer Shalev
   */
  public class FbPhotoPoster extends GraphRequest
  {
    private var _imgBinary:   ByteArray         = null;
    private var _imgMessage:  String            = null;
    private var _userId:      String            = null;
    
    /**
     * we use <code>URLRequestBuilder</code> and <code>URLFileVariable</code>, this is a deviation from the <code>GraphRequest</code> api for
     * the benefir of uploading binary images to Facebook
     */
    private var _urb:       URLRequestBuilder = null;
    private var _ufv:       URLFileVariable   = null;
    
    /**
     * Facebook photo poster<br>
     * <b>Notes:</b>
     * <li>use <code>this.imgBinray</code> to set a compressed binary image</li>
     * <li>use <code>this.imgMessage</code> to set a caption to the posted image</li>
     * <li>this class is optimized for memory and promotes reusing. objects are instantiated once</li>
     * @param $userId the id of the facebook profile to upload the image to.
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function FbPhotoPoster($userId:String = "me", $access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      _userId     = $userId;
      //_userId     = "me";
      
      _imgMessage = "";
      
      _urb        = new URLRequestBuilder();
      _ufv        = new URLFileVariable();
      
      super("/" + _userId + "/photos", URLRequestMethod.POST, $access_token, $access_tokenExpiry);
    }
    
    /**
     * post the image to Facebook 
     * @param $onUpdate callback
     */
    public function postImage($onUpdate:Function = null):void
    {
      // had to bypass loadRequest method because this is a special request with multi-part binary data
      
      cb_onUpdate                     = $onUpdate;
      
      _ufv.data                       = _imgBinary;
      _ufv.name                       = "img.jpg";
      
      _urlVariables["source"]         = _ufv;
      _urlVariables["message"]        = _imgMessage;      
      
      _urb.variables                  = _urlVariables;
      //loadRequest(params, null, $onUpdate);
      
      _ur                             = _urb.build(_ur);
      
      _ul.addEventListener( Event.COMPLETE, onGraphRequestResponse);
      _ul.load(_ur);
    }
    
    public function clearData():void
    {
      if(_imgBinary)
        _imgBinary.clear();
      
      cb_onUpdate = null;
    }
    /**
     * the binary image to post in JPEG, GIF or PNG formats.
     */
    public function get imgBinary():                ByteArray { return _imgBinary;  }
    public function set imgBinary(value:ByteArray): void      { _imgBinary = value; }
    
    /**
     * caption message to be posted with the image 
     */
    public function get imgMessage():               String    { return _imgMessage; }
    public function set imgMessage(value:String):   void      { _imgMessage = value;}
    
    public function get userId():                   String    { return _userId;     }
    public function set userId(value:String):       void      { _userId = value;    }
    
  }
}