package com.hendrix.facebook.auth
{
  public class FacebookAuthBase implements IFacebookAuth
  {
    protected var _appId:                             String                = null;
    
    protected var _accessToken:                       String                = null;
    protected var _accessTokenExpiry:                 Number                = -1;
    protected var _accessTokenDebug:                  String                = null;
    
    protected var _readPermissions:                   String                = null;
    protected var _publishPermissions:                String                = null;//"publish_stream,publish_actions,status_update";
    
    protected var _isPublishPermissionsGranted:       Boolean               = false;
    protected var _isReadPermissionsGranted:          Boolean               = false;
    
    protected var _status:                            String                = null;
    
    public var cb_onLoginUpdate:                      Function              = null;
    public var cb_onPublishPermmisionsUpdate:         Function              = null;
    
    public function FacebookAuthBase($appId:String, $readPermmisions:String = "basic_info", $publishPermmisions:String = null)
    {
      _appId              = $appId;
      _readPermissions    = $readPermmisions;
      _publishPermissions = $publishPermmisions;
    }
    
    public function loginFacebook($onLoginUpdate:Function=null):void
    {
      cb_onLoginUpdate = $onLoginUpdate;
    }
    
    public function logoutFacebook():void
    {
      _status = FacebookStatus.FB_LOGGED_OUT;
    }
    
    public function dispose():void
    {
      cb_onLoginUpdate  = null;
    }
    
    public function requestPublishPermissions($permissions:String = null):void
    {
      
    }
    
    /**
     * an event listener for native login, here i suggest handling all login events such as loggedin.loggedout,failed, cancelled 
     * @param event an event object
     */
    public function onLoginUpdate(event:*):void
    {
    }
    
    public function onPublishPermissionsUpdated(event:Object):void
    {
      
    }
    
    
    /**
     * notify our one and only listener 
     */
    protected function notifyLoginListener():void
    {
      if(cb_onLoginUpdate is Function)
        cb_onLoginUpdate();
    }
    
    /**
     * notify our one and only publish permmisions listener 
     */
    protected function notifyPublishPermmisionsListener(granted:Boolean):void
    {
      if(cb_onPublishPermmisionsUpdate is Function)
        cb_onPublishPermmisionsUpdate(granted);
    }
    
    public function get readPermissions():                String  { return _readPermissions;  }
    public function set readPermissions(value:String):    void    { _readPermissions = value; }
    
    public function get publishPermissions():             String  { return _publishPermissions; }
    public function set publishPermissions(value:String): void    { _publishPermissions = value;}
    
    public function get status():                         String  { return _status; }
    
    public function get isPublishPermissionsGranted():    Boolean { return _isPublishPermissionsGranted;  }
    
    public function get isReadPermissionsGranted():       Boolean { return _isReadPermissionsGranted; }
    
    public function get accessTokenDebug():               String  { return _accessTokenDebug;   }
    public function set accessTokenDebug(value:String):   void    { _accessTokenDebug = value;  }
    
    public function get accessToken():                    String  { return _accessToken;  }
    public function set accessToken(value:String):        void    { _accessToken = value; }
    
    public function get accessTokenExpiry():              Number  { return _accessTokenExpiry;  }
    public function set accessTokenExpiry(value:Number):  void    { _accessTokenExpiry = value; }
    
    public function get appId():                          String  { return _appId;  }
    
  }
}