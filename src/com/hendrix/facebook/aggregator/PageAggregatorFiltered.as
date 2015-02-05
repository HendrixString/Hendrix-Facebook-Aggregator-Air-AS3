package com.hendrix.facebook.aggregator
{
  import flash.utils.Dictionary;
  
  import com.hendrix.facebook.aggregator.core.AggregatorBase;
  
  /**
   * Facebook feed aggregator, non filtered.
   * 
   * @author Tomer Shalev
   */
  public class PageAggregatorFiltered extends AggregatorBase
  {
    protected var _pageId:                      String        = null;
    protected var _posterId:                    String        = null;
    
    private var _userDic:                       Dictionary    = null;
    
    private var _mapFqlResults:                 Dictionary    = null;
    
    /**
     * Facebook posts aggregator.
     * @param $pageId the Facebook page id to be aggregated
     * @param $access_token a valid facebook access token
     * @param $access_tokenExpiry token expiry date
     */
    public function PageAggregatorFiltered($pageId: String, $posterId:String = null ,$access_token:String = null, $access_tokenExpiry:Number = -1)
    {
      super($access_token, $access_tokenExpiry);
      
      _posterId = $posterId;
      _pageId   = $pageId;
      
      _userDic = new Dictionary(true);
      
      _mapFqlResults = new Dictionary();
    }
    
    /**
     * @inheritDoc
     */
    override public function refreshFeed($onWallFeedUpdate:Function=null):Boolean
    {
      _fql["query1"]                  = "SELECT actor_id,created_time,message,post_id,like_info,comment_info,share_info,attachment,actor_id,permalink FROM stream WHERE source_id=" + _pageId + " and actor_id=" + _posterId + " LIMIT " + AGGREGATOR_PACKET_SIZE;
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT actor_id FROM #query1))";
      
      return (super.refreshFeed($onWallFeedUpdate));
    }
    
    /**
     * @inheritDoc
     */
    override public function nextPageFeed($onWallFeedUpdate:Function=null):Boolean
    {
      if(_posts.length == 0)
        return refreshFeed($onWallFeedUpdate);
      
      _fql["query1"]                  = "SELECT actor_id,created_time,message,post_id,like_info,comment_info,share_info,attachment,actor_id,permalink FROM stream WHERE source_id=" + _pageId + " and actor_id=" + _posterId + " and created_time<" + _posts[_posts.length - 1].created_time + " ORDER BY created_time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT actor_id FROM #query1))";
      
      return (super.nextPageFeed($onWallFeedUpdate));
    }
    
    override public function prevPageFeed($onWallFeedUpdate:Function=null):Boolean
    {
      if(_posts.length == 0)
        return refreshFeed($onWallFeedUpdate);
      
      _fql["query1"]                  = "SELECT actor_id,created_time,message,post_id,like_info,comment_info,share_info,attachment,actor_id,permalink FROM stream WHERE source_id=" + _pageId + " and actor_id=" + _posterId + " and created_time>" + _posts[0].created_time + " ORDER BY created_time DESC LIMIT " + AGGREGATOR_PACKET_SIZE;
      _fql["users_info"]              = "SELECT uid,pic_small, pic_square,name FROM user WHERE (uid IN (SELECT actor_id FROM #query1))";
      
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
      
      var posts:          Array   = _mapFqlResults["query1"] as Array;
      var userInfo: Array   = _mapFqlResults["users_info"] as Array;
      var post:           Object  = null;
      var ix:             int;
      var count_filtered: uint    = 0;
      
      if(posts.length == 0)
        return 0;
      
      switch($position)
      {
        case "TOP":
        {
          for(ix = posts.length - 1; ix >= 0; ix--) {
            // add comments vector to posts
            //posts[ix].comments    = new Vector.<Object>;
            if(isEmptyPost(posts[ix])) {
              count_filtered += 1;
              continue;
            }
            
            _posts.unshift(posts[ix]);
          }
          break;
        }
        case "BOTTOM":
        {
          for(ix = 0; ix < posts.length; ix++)  {
            // add comments vector to posts
            //posts[ix].comments    = new Vector.<Object>;
            if(isEmptyPost(posts[ix])) {
              count_filtered += 1;
              continue;
            }
            
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
      
      for(ix = 0; ix < userInfo.length; ix++) {
        _userDic[userInfo[ix].uid] = userInfo[ix];
      }
      
      for(ix = 0; ix < posts.length; ix++)  {
        posts[ix].users_info = _userDic[posts[ix].actor_id];
      }
      
      /*
      // add comments
      for(ix = 0; ix < posts_comments.length; ix++) {
      post                      = _posts.getById(posts_comments[ix].post_id);
      post.comments.push(posts_comments[ix]);
      }
      */
      
      return (posts.length - count_filtered);
    }
    
    private function isEmptyPost(post:Object):Boolean
    {
      //if(post.message == "")
      //  return true;
      
      if( !(post.attachment as Object).hasOwnProperty("media") && (post.message == ""))
        return true
      
      return false;
    }
    
    public function get posterId():String { return _posterId; }
    public function set posterId(value:String):void
    {
      _posterId = value;
    }
    
    
  }
}