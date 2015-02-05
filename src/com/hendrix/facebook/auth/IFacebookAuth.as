package com.hendrix.facebook.auth
{
  /**
   * a common interface for Facebook authentication methods and login 
   * @author Tomer Shalev
   */
  public interface IFacebookAuth
  {
    /**
     * login Facebook method 
     * @param $onLoginUpdate an outside listener
     */
    function loginFacebook($onLoginUpdate:  Function = null): void;
    
    /**
     * logout Facebook 
     */
    function logoutFacebook():                                void;
    
    /**
     *  login update event handler  
     */
    function onLoginUpdate(event:*):void;
    
    /**
     *  publish permmisions event handler  
     */
    function onPublishPermissionsUpdated(event:Object):void;
    
    /**
     * request publish permmisions
     */
    function requestPublishPermissions($permissions:String = null):void;
    
    /**
     *  dispose 
     */
    function dispose():                                       void;
    
    /**
     * read permissions 
     */
    function get readPermissions():                           String;
    function set readPermissions(value:String):               void;
    
    /**
     * publish permissions 
     */
    function get publishPermissions():                        String;
    function set publishPermissions(value:String):            void;
    
    /**
     * login status: FB_LOGGED_IN or FB_LOGGED_OUT
     */
    function get status():                                    String;
    
    /**
     * check if publish permissions were granted by Facebook
     */
    function get isPublishPermissionsGranted():               Boolean;
    
    /**
     * access token for developer mode, a fallback. useful is to record an access token and use it later. 
     */
    function get accessTokenDebug():                          String;
    function set accessTokenDebug(value:String):              void;
    
    /**
     * a valid Facebook access token 
     */
    function get accessToken():                               String;
    function set accessToken(value:String):                   void;
    
    /**
     * a Facebook Expiry stamp of the access token 
     */
    function get accessTokenExpiry():                         Number;
    function set accessTokenExpiry(value:Number):             void;
    
    /**
     * the Facebook application id 
     */
    function get appId():                                     String;
    
  }
}