package com.hendrix.facebook.commands
{
  import flash.net.URLRequestMethod;
  
  import com.hendrix.facebook.core.GraphRequest;
  
  public class FbPostWall extends GraphRequest
  {
    private var _userId:  String = null;
    
    public function FbPostWall($userId:String="me", $access_token:String=null, $access_tokenExpiry:Number=-1)
    {
      _userId = $userId;
      
      super("/" + _userId + "/feed", URLRequestMethod.POST, $access_token, $access_tokenExpiry);
    }
    
    
    public function postToWall($onUpdate:Function = null, $message:String = "", $picture:String = "", $link:String = "", $description:String = "", $caption:String = ""):void
    {
      path = "/" + _userId + "/feed";
      
      params["message"]     = $message;
      params["picture"]     = $picture;
      params["link"]        = $link;
      params["description"] = $description;
      params["caption"]     = $caption;
      
      loadRequest(params, null, $onUpdate);
    }
    
    public function get userId():             String  { return _userId; }
    public function set userId(value:String): void  
    {
      _userId = value;
    }
    
  }
}