package com.hendrix.facebook.auth
{
  /**
   * Facebook auth services for mobile, uses GoViral as it's carrier
   * @author Tomer Shalev
   */
  public class FacebookAuthMobile extends FacebookAuthBase
  {
    
    /**
     * Facebook auth services for mobile, uses GoViral as it's carrier
     * @param $appId the Facebook application id
     * @param $readPermmisions requested read permmissions
     * @param $publishPermmisions requested publish permmissions
     */
    
    /*
    public function FacebookAuthMobile($appId:String, $readPermmisions:String = "basic_info", $publishPermmisions:String = null)
    {
    super($appId, $readPermmisions, $publishPermmisions);
    
    _accessTokenDebug = "CAACEdEose0cBALoIlyBQUvBCXNc8nBEjZALatuOKGZBlozHwQzZC058CVYZBp9gS0Bgr8OkP8KGxcWwN9WX73mjCTHTMb7gNPTckrlf7dSdZCZASlEWKX3SmgkVZBbX76b2JXnawfUKUZA2fUvflr3nd93wPAV0WsxZAPvZBEJPJ58IF9w4BOy2MYszDVzjoZAubxcZD";
    
    if(GoViral.isSupported()) 
    {
    GoViral.create();
    
    if(GoViral.goViral.isFacebookSupported() == false)
    return;
    
    facebookInitandEvents();
    }
    }
    
    override public function loginFacebook($onLoginUpdate:  Function = null):void
    {
    super.loginFacebook($onLoginUpdate);
    
    if(GoViral.isSupported() == false) {
    // use debug token
    // callbaack
    // developer mode for desktop
    if(_accessTokenDebug) {
    _accessToken  = _accessTokenDebug;
    _isPublishPermissionsGranted = true;
    _status       = FacebookStatus.FB_LOGGED_IN;
    notifyLoginListener();
    }
    
    return;
    }
    
    GoViral.goViral.initFacebook(_appId, "");
    
    if(GoViral.goViral.isFacebookAuthenticated() == false)
    GoViral.goViral.authenticateWithFacebook(_readPermissions);
    }
    */
    /** 
     * Logout of facebook 
     */
    /*
    override public function logoutFacebook():void
    {
    super.logoutFacebook();
    GoViral.goViral.logoutFacebook();
    }
    */
    /**
     * this seems to be only required for mobile, asking publish only after read permissions.
     * should only be used once, when the user first authenticates the app after login.
     * it will not change the access token as access token for mobile will not reflect publish permissions
     * anymore, only read permissions. 
     * @param $permissions permissions
     */
    /*
    override public function requestPublishPermissions($permissions:String = null):void
    {
    if(GoViral.isSupported() == false) {
    cb_onPublishPermmisionsUpdate(_isPublishPermissionsGranted);
    }
    
    if($permissions)
    _publishPermissions = $permissions;
    
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED, onPublishPermissionsUpdated);
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED,  onPublishPermissionsUpdated);
    GoViral.goViral.requestNewFacebookPublishPermissions(_publishPermissions);
    }
    
    override public function onLoginUpdate(event:*):void
    {
    if(event.type != GVFacebookEvent.FB_LOGGED_IN) {
    _status = FacebookStatus.FB_LOGGED_OUT;
    notifyLoginListener()
    return;
    }
    
    _status                   = FacebookStatus.FB_LOGGED_IN;
    _isReadPermissionsGranted = true;
    _accessToken              = GoViral.goViral.getFbAccessToken();
    
    
    if(_publishPermissions == null) {
    notifyLoginListener()
    return;
    }
    
    if(GoViral.isSupported() == false) {
    notifyLoginListener();
    return;
    }
    
    notifyLoginListener();
    
    if(_publishPermissions)
    requestPublishPermissions(_publishPermissions);
    }
    
    private function facebookInitandEvents():void
    {
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_IN,                        onLoginUpdate);
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGGED_OUT,                       onLoginUpdate);
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_CANCELED,                   onLoginUpdate);
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_LOGIN_FAILED,                     onLoginUpdate);
    
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_FAILED,          onReadPermmision);
    GoViral.goViral.addEventListener(GVFacebookEvent.FB_READ_PERMISSIONS_UPDATED,         onReadPermmision);
    }
    */
    /**
     * this might not be relevant anymore. logging in is always granted with read permmisions 
     */
    /*
    protected function onReadPermmision(event:Event):void
    {
    switch(event.type) {
    case GVFacebookEvent.FB_READ_PERMISSIONS_FAILED:
    {
    _isReadPermissionsGranted = false;
    break;
    }
    case GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED:
    {
    _isReadPermissionsGranted = true;
    break;
    }
    }
    }
    
    override public function onPublishPermissionsUpdated(event:Object):void
    {
    GoViral.goViral.removeEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED, onPublishPermissionsUpdated);
    GoViral.goViral.removeEventListener(GVFacebookEvent.FB_PUBLISH_PERMISSIONS_FAILED,  onPublishPermissionsUpdated);
    
    _accessToken                    = GoViral.goViral.getFbAccessToken();
    
    if((event as GVFacebookEvent).type == GVFacebookEvent.FB_PUBLISH_PERMISSIONS_UPDATED) {
    _isPublishPermissionsGranted  = true;
    }
    
    notifyPublishPermmisionsListener(_isPublishPermissionsGranted)
    }
    */
  }
}