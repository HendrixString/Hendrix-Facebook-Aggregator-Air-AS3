package com.hendrix.facebook.commands
{
  import flash.net.URLRequestMethod;
  
  import com.hendrix.facebook.core.GraphRequest;
  
  public class FbComment extends GraphRequest
  {
    
    public function FbComment($postId:String, $comment:String = null, $access_token:String=null, $access_tokenExpiry:Number=-1)
    {
      super($postId + "/comments", URLRequestMethod.POST, $access_token, $access_tokenExpiry);
      
      if($comment)
        postComment($comment);
    }
    
    /**
     * we are reusing this instance over and over that's why i modify the url. 
     * @param $postId
     * @param $onUpdate
     * 
     */
    public function postComment($comment:String, $postId:String = null, $onUpdate:Function = null):void
    {
      stopRequest();
      
      if($postId)
        _ur.url             = "https://graph.facebook.com/" + $postId + "/comments";
      
      if($comment)
        params["message"]   = $comment;
      
      loadRequest(params, null, $onUpdate);
    }
    
  }
}