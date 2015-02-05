package com.hendrix.facebook.aggregator
{
  import flash.utils.Dictionary;
  
  import com.hendrix.facebook.aggregator.core.AggregatorBase;
  
  /**
   * Facebook feed aggregator, non filtered.
   * 
   * @author Tomer Shalev
   */
  public class PostsSetAggregator extends AggregatorBase
  {
    private var _userDic:                       Dictionary      = null;
    
    private var _mapFqlResults:                 Dictionary      = null;
    
    private var _postsIDs:                      Vector.<String> = null;
    private var _strPostIDs:                    String          = null;
    
    /**
     * Facebook posts aggregator.
     * @param $pageId the Facebook page id to be aggregated
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function PostsSetAggregator($access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      super($access_token, $access_tokenExpiry);
      
      _userDic        = new Dictionary(true);
      
      _mapFqlResults  = new Dictionary();
    }
    
    private function compilePostIds():String
    {
      var cPostsIds:  uint   = _postsIDs.length;
      
      _strPostIDs            =  " (";
      
      for(var ix:uint = 0; ix < cPostsIds; ix++)
      {
        _strPostIDs += "'" + _postsIDs[ix] + "'";
        if(ix < cPostsIds - 1)
          _strPostIDs       += ",";
      }
      
      _strPostIDs           += ")";
      
      return _strPostIDs;
    }
    
    /**
     * @inheritDoc
     */
    override public function refreshFeed($onWallFeedUpdate:Function = null):Boolean
    {
      _fql["query1"]                  = "SELECT actor_id,created_time,message,post_id,like_info,comment_info,attachment,permalink,share_info FROM stream WHERE (post_id IN " + compilePostIds() + " ) ORDER BY created_time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;        
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT actor_id FROM #query1))";
      _fql["pages_info"]              = "SELECT page_id,pic_small, pic_square,name FROM page WHERE (page_id IN (SELECT actor_id FROM #query1))";
      
      return (super.refreshFeed($onWallFeedUpdate));
    }
    
    /**
     * @inheritDoc
     */
    override public function nextPageFeed($onWallFeedUpdate:Function = null):Boolean
    {     
      if(_posts.length == 0)
        return refreshFeed($onWallFeedUpdate);
      
      return true;
      
      return super.nextPageFeed($onWallFeedUpdate);
    }
    
    /**
     * @inheritDoc
     */
    override public function prevPageFeed($onWallFeedUpdate:Function = null):Boolean
    {     
      return true;
      
      return refreshFeed($onWallFeedUpdate);
      
      if(_posts.length == 0)
        return refreshFeed($onWallFeedUpdate);
      
      return (super.prevPageFeed($onWallFeedUpdate));
    }
    
    private function mapRsults($feed:Object = null):void
    {
      for(var ix:uint = 0; ix < $feed.data.length; ix++) {
        _mapFqlResults[$feed.data[ix].name] = $feed.data[ix].fql_result_set;
      }
    }
    
    /**
     * @inheritDoc
     */
    override public function processFeed($feed:Object, $position:String = "BOTTOM"):uint
    {
      mapRsults($feed);
      
      var posts:      Array   = _mapFqlResults["query1"]      as Array;
      var userInfo:   Array   = _mapFqlResults["users_info"]  as Array;
      var pagesInfo:  Array   = _mapFqlResults["pages_info"]  as Array;
      var post:       Object  = null;
      var ix:         int;
      
      if(posts.length == 0)
        return 0;
      
      switch($position)
      {
        case "TOP":
        {
          for(ix = posts.length - 1; ix >= 0; ix--) {
            // add comments vector to posts
            posts[ix].comments    = new Vector.<Object>;
            _posts.unshift(posts[ix]);
          }
          break;
        }
        case "BOTTOM":
        {
          for(ix = 0; ix < posts.length; ix++)  {
            // add comments vector to posts
            posts[ix].comments    = new Vector.<Object>;
            _posts.push(posts[ix]);
          }
          break;
        }
        default:
        {
          throw new Error("invalid argument position: should be BOTTOM or TOP");
          break;
        }
      }
      
      var len_userInfo:uint = userInfo.length;
      var len_pageInfo:uint = pagesInfo.length;
      
      for(ix = 0; ix < len_userInfo; ix++)  {
        _userDic[userInfo[ix].uid] = userInfo[ix];
      }
      
      for(ix = 0; ix < len_pageInfo; ix++)  {
        _userDic[pagesInfo[ix].page_id] = pagesInfo[ix];
      }
      
      var userName:String;
      for(ix = 0; ix < posts.length; ix++)  {
        posts[ix].users_info = _userDic[posts[ix].actor_id];
      }
      
      return posts.length;
    }
    
    public function get postsIDs():                       Vector.<String> { return _postsIDs; }
    public function set postsIDs(value:Vector.<String>):  void
    {
      _postsIDs = value;
      disposeFeedData();
    }
    
  }
}