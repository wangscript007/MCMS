﻿UPDATE `mdiy_tag_sql` SET `tag_id` = 3, `tag_sql` = '<#assign _typeid=\"\"/>\r\n<#assign _size=\"20\"/>\r\n<#if column?? && column.id?? && column.id?number gt 0>\r\n  <#assign  _typeid=\"${column.id}\">\r\n</#if>\r\n<#if typeid??>\r\n  <#assign  _typeid=\"${typeid}\">\r\n</#if>\r\n<#if size??>\r\n  <#assign  _size=\"${size}\">\r\n</#if>\r\n<#if orderby?? >\r\n      <#if orderby==\"date\"> \r\n	   <#assign  _orderby=\"content_datetime\">\r\n      <#elseif orderby==\"updatedate\">\r\n <#assign  _orderby=\"content_updatetime\">\r\n      <#elseif orderby==\"hit\"> \r\n	  <#assign  _orderby=\"content_hit\">\r\n      <#elseif orderby==\"sort\">\r\n	   <#assign  _orderby=\"content_sort\">\r\n      <#else><#assign  _orderby=\"cms_content.id\"></#if>\r\n   <#else>\r\n   <#assign  _orderby=\"cms_content.id\">\r\n  </#if>\r\nSELECT\r\n  cms_content.id AS id,\r\n  @rownum := @rownum + 1 AS `index`,\r\n  LEFT (content_title, ${titlelen ?default(40)}) AS title,\r\n  content_title AS fulltitle,\r\n  content_author AS author,\r\n  content_source AS source,\r\n  content_details AS content,\r\n  category.category_title AS typename,\r\n  category.id AS typeid,\r\n  category.category_img AS typelitpic,\r\n  <#--列表页动态链接-->\r\n  <#if isDo?? && isDo>\r\n  CONCAT(\"/${modelName}/list.do?typeid=\", category.category_id) as typelink,\r\n  <#else>\r\n  (SELECT \"index.html\") AS typelink,\r\n  </#if>\r\n  content_img AS litpic,\r\n  <#--内容页动态链接-->\r\n  <#if isDo?? && isDo>\r\n   CONCAT(\"/${modelName}/view.do?id=\", cms_content.id,\"&orderby=${_orderby}\",\"&order=${order!\'ASC\'}\",\"&typeid=${typeid}\") as link,\r\n  <#else>\r\n\r\n  CONCAT(category.category_path,\"/\",cms_content.id,\".html\") AS link,\r\n  </#if>\r\n  content_datetime AS date,<#if tableName??>${tableName}.*,</#if>\r\n  content_description AS descrip,\r\n  content_hit AS hit,\r\n  content_type AS flag,\r\n  category_title AS typetitle,\r\n  cms_content.content_keyword AS keyword \r\nFROM\r\n  (SELECT @rownum := 0) r,\r\n  cms_content\r\n  LEFT JOIN cms_category as category ON content_category_id = category.id\r\n  <#--判断是否有自定义模型表-->\r\n  <#if tableName??>LEFT JOIN ${tableName} ON ${tableName}.link_id=cms_content.id </#if>\r\nWHERE  \r\n  content_display=0 \r\n	and cms_content.del=0 \r\n  <#--根据站点编号查询-->\r\n  <#if appId?? >\r\n    and cms_content.app_id=${appId}\r\n	and cms_content.id>0\r\n  </#if>\r\n  <#--判断是否有搜索分类集合-->\r\n  <#if search??>\r\n		<#if search.categoryIds??>and FIND_IN_SET(category.id,\'${search.categoryIds}\')</#if>\r\n			<#--标题-->\r\n			<#if search.content_title??> and content_title like CONCAT(\"%\",\'${search.content_title}\',\"%\")</#if>\r\n			<#--作者-->\r\n			<#if search.content_author??> and content_author like CONCAT(\"%\",\'${search.content_author}\',\"%\")</#if>\r\n			<#--来源-->\r\n			<#if search.content_source??> and content_source like CONCAT(\"%\",\'${search.content_source}\',\"%\")</#if>\r\n			<#--属性-->\r\n			<#if search.content_type??> and  (\r\n			<#list search.content_type?split(\',\') as item>\r\n			<#if item?index gt 0> or</#if>\r\n			FIND_IN_SET(\'${item}\',cms_content.content_type)\r\n			</#list>)</#if>\r\n			<#--描述-->\r\n			<#if search.content_description??> and content_description like CONCAT(\"%\",\'${search.content_description}\',\"%\")</#if>\r\n			<#--关键字-->\r\n			<#if search.content_keyword??> and content_keyword like CONCAT(\"%\",\'${search.content_keyword}\',\"%\")</#if>\r\n			<#--内容-->\r\n			<#if search.content_details??> and content_details like CONCAT(\"%\",\'${search.content_details}\',\"%\")</#if>\r\n			\r\n<#--自定义顺序-->\r\n			<#if search.content_sort??> and content_sort=${search.content_sort}</#if>		\r\n<#--时间范围-->\r\n			<#if search.content_datetime_start??&&search.content_datetime_end??> and content_datetime between \'${search.content_datetime_start}\' and \'${search.content_datetime_end}\'</#if>\r\n  <#else><#--查询栏目-->\r\n    <#if _typeid?has_content> and (content_category_id=${_typeid} or content_category_id in \r\n  (select id FROM cms_category where cms_category.del=0 and find_in_set(${_typeid},CATEGORY_PARENT_ID))) </#if>\r\n </#if>\r\n  <#--标题-->\r\n  <#if content_title??> and content_title like CONCAT(\"%\",\'${content_title}\',\"%\")</#if>\r\n  <#--作者-->\r\n  <#if content_author??> and content_author like CONCAT(\"%\",\'${content_author}\',\"%\")</#if>\r\n  <#--来源-->\r\n  <#if content_source??> and content_source like CONCAT(\"%\",\'${content_source}\',\"%\")</#if>\r\n  <#--属性-->\r\n  <#if content_type??> and content_type like CONCAT(\"%\",\'${content_type}\',\"%\")</#if>\r\n  <#--描述-->\r\n  <#if content_description??> and content_description like CONCAT(\"%\",\'${content_description}\',\"%\")</#if>\r\n  <#--关键字-->\r\n  <#if content_keyword??> and content_keyword like CONCAT(\"%\",\'${content_keyword}\',\"%\")</#if>\r\n  <#--内容-->\r\n  <#if content_details??> and content_details like CONCAT(\"%\",\'${content_details}\',\"%\")</#if>\r\n  <#--自定义顺序-->\r\n  <#if content_sort??> and content_sort=${content_sort}</#if>\r\n  <#--自定义模型-->\r\n  <#if diyModel??> \r\n    <#list diyModel as dm>\r\n      and ${tableName}.${dm.key} like CONCAT(\"%\",\'${dm.value}\',\"%\") \r\n    </#list>\r\n  </#if>\r\n  <#--文章属性-->\r\n  <#if flag?? >\r\n			and(\r\n			<#list flag?split(\',\') as item>\r\n			<#if item?index gt 0> or</#if>\r\n			FIND_IN_SET(\'${item}\',cms_content.content_type)\r\n			</#list>)\r\n  </#if>\r\n  <#if noflag??>\r\n			and(\r\n			<#list noflag?split(\',\') as item>\r\n			<#if item?index gt 0> and</#if>\r\n			FIND_IN_SET(\'${item}\',cms_content.content_type)=0\r\n			</#list> or cms_content.content_type is null)\r\n  </#if>\r\n  <#--字段排序-->\r\n  <#if orderby?? >\r\n    ORDER BY \r\n      <#if orderby==\"date\"> content_datetime\r\n      <#elseif orderby==\"updatedate\"> content_updatetime\r\n      <#elseif orderby==\"hit\"> content_hit\r\n      <#elseif orderby==\"sort\"> content_sort\r\n      <#else>cms_content.id</#if>\r\n <#else>\r\n    ORDER BY   cms_content.id\r\n  </#if>\r\n  <#if order?? >\r\n      <#if order==\"desc\"> desc</#if>\r\n      <#if order==\"asc\"> asc</#if>\r\n  </#if>\r\n   LIMIT \r\n    <#--判断是否分页-->\r\n  <#if ispaging?? && (pageTag.pageNo)??>${((pageTag.pageNo-1)*_size?eval)?c},${_size?default(20)}\r\n  <#else>${_size?default(20)}</#if>', `sort` = 1 WHERE `id` = 5;
UPDATE `mdiy_tag_sql` SET `tag_id` = 4, `tag_sql` = '<#assign _typeid=\"0\"/>\r\n<#if column?? && column.id?? && column.id?number gt 0>\r\n	<#assign  _typeid=\"${column.id}\">\r\n	<#assign  selfid=\"${column.id}\">\r\n</#if>\r\n<#if typeid??>\r\n	<#assign  _typeid=\"${typeid}\">\r\n</#if>\r\nselect \r\n	@rownum := @rownum + 1 AS typeindex,\r\n	id,\r\n	id as typeid,\r\n	category_title as typetitle,\r\n	<#--返回父id集合-->\r\n	category_parent_id as pids,\r\n	<#--栏目选中的样式-->\r\n	IF(<#if selfid?has_content>${selfid}<#else>${_typeid}</#if> = id ,\"${class!\'\'}\",\"\") as class,\r\n	<#--动态链接-->\r\n	<#if isDo?? && isDo>\r\n	CONCAT(\"/${modelName}/list.do?typeid=\", id) as typelink,\r\n	<#else>\r\n		<#--栏目类型为链接-->\r\n		IF(\"3\" = category_type,category_diy_url,CONCAT(category_path,\"/index.html\")) as typelink,\r\n	</#if>\r\n	category_keyword as typekeyword,\r\n	category_diy_url as typeurl,\r\n	category_flag as flag,\r\n category_parent_id as parentid,\r\ncategory_descrip as typedescrip,\r\n	category_img as typelitpic ,\r\n(select count(*) from cms_category c where c.category_id=typeid and c.del=0) as childsize\r\n	from (SELECT @rownum := 0) r,cms_category  \r\n	where \r\n	cms_category.del=0 \r\n	<#--根据站点编号查询-->\r\n	<#if appId?? >\r\n		and cms_category.app_id=${appId}\r\n	</#if>\r\n	<#--栏目属性-->\r\n	  <#if flag?? >\r\n   and\r\n	(		<#list flag?split(\',\') as item>\r\n			<#if item?index gt 0> or</#if>\r\n			FIND_IN_SET(\'${item}\',category_flag)\r\n			</#list>)\r\n  </#if>\r\n\r\n	<#if noflag?? >\r\n      and\r\n			(\r\n			<#list noflag?split(\',\') as item>\r\n			<#if item?index gt 0> and</#if>\r\n			FIND_IN_SET(\'${item}\',category_flag)=0\r\n			</#list> or category_flag is null)\r\n	</#if>\r\n	<#--type默认son-->\r\n<#if !type??||!type?has_content>\r\n<#assign type=\"son\"/>\r\n</#if>\r\n<#if type?has_content>\r\n	<#--顶级栏目（单个）-->\r\n	<#if type==\"top\">\r\n	<#if _typeid != \"0\">\r\n		and id=(SELECT IF(IF(LEFT ( category_parent_id, LOCATE( \",\", category_parent_id ) - 1 ),LEFT ( category_parent_id, LOCATE( \",\", category_parent_id ) - 1 ),category_parent_id),IF(LEFT ( category_parent_id, LOCATE( \",\", category_parent_id ) - 1 ),LEFT ( category_parent_id, LOCATE( \",\", category_parent_id ) - 1 ),category_parent_id),id)FROM cms_category WHERE id = ${_typeid})\r\n		</#if>\r\n	<#elseif type==\"nav\">\r\n		and(category_id=0 or category_id is null)\r\n	<#--同级栏目（多个）-->\r\n	<#elseif type==\"level\">\r\n		and\r\n		<#if _typeid?has_content>\r\n		 category_id=(select category_id from cms_category where id=${_typeid})\r\n		<#else>\r\n		 1=1\r\n		</#if>\r\n  	<#--当前栏目（单个）-->\r\n	<#elseif type==\"self\">\r\n		 and \r\n		 <#if _typeid?has_content>\r\n		  id=${_typeid}\r\n		 <#else>\r\n		 1=1\r\n		 </#if>\r\n	<#--当前栏目的所属栏目（多个）-->\r\n	<#elseif type==\"path\">\r\n			and \r\n		 <#if _typeid?has_content>\r\n		   id in (<#if column?? && column.categoryParentId??>${column.categoryParentId},</#if>${_typeid})\r\n		 <#else>\r\n		  1=1\r\n		 </#if>\r\n	<#--子栏目（多个）-->\r\n	<#elseif type==\"son\">\r\n			and \r\n		 <#if _typeid?has_content>\r\n		  category_id=${_typeid}\r\n		 <#else>\r\n		  1=1\r\n		 </#if>\r\n		 <#--上一级栏目没有则取当前栏目（单个）-->\r\n	<#elseif type==\"parent\">\r\n			and \r\n		 <#if _typeid?has_content>\r\n		   <#if column?? && column.categoryId??>\r\n				id=${column.categoryId}\r\n			 <#else>\r\n			  id=${_typeid}\r\n			 </#if>\r\n		 <#else>\r\n		  1=1\r\n	</#if>\r\n	<#--子栏目或同级栏目（多个）-->\r\n	<#elseif type==\"sonOrLevel\">\r\n		 and \r\n		 <#if _typeid?has_content>\r\n	 	 category_id= if((SELECT count(*) FROM cms_category\r\n		 WHERE category_id=${_typeid})>0,${_typeid},(select category_id from cms_category where id=${_typeid}))\r\n		 <#else>\r\n		 1=1\r\n		 </#if>\r\n	</#if>\r\n<#else> <#--默认顶级栏目-->\r\n	 and\r\n	<#if _typeid?has_content>\r\n	 id=${_typeid}\r\n	<#else>\r\n	 (category_id=0 or category_id is null)\r\n	</#if>\r\n</#if>\r\n<#--字段排序-->\r\n  <#if orderby?? >\r\n    ORDER BY \r\n      <#if orderby==\"date\"> category_datetime\r\n      <#elseif orderby==\"sort\"> category_sort\r\n      <#else>cms_content.id</#if>\r\n <#else>\r\n    ORDER BY   id\r\n  </#if>\r\n  <#if order?? >\r\n      <#if order==\"desc\"> desc</#if>\r\n      <#if order==\"asc\"> asc</#if>\r\n  </#if>', `sort` = 1 WHERE `id` = 6;
UPDATE `mdiy_tag_sql` SET `tag_id` = 5, `tag_sql` = 'select \r\nAPP_NAME as name,\r\napp_logo as logo ,\r\napp_keyword as keyword,\r\napp_description as descrip,\r\napp_copyright as copyright,\r\n<#--动态解析 -->\r\n<#if isDo?? && isDo>\r\nCONCAT(\"${url}\",\"/${html}/\",id) as url,\r\n\"${url}\" as host,\r\n<#--使用地址栏的域名 -->\r\n<#elseif url??>\r\nCONCAT(\"${url}\",\"/${html}/\",id,\"/<#if m??>${m}</#if>\") as url,\r\n\"${url}\" as host,\r\n<#else>\r\nCONCAT(REPLACE(REPLACE(TRIM(substring_index(app_url,\"\\n\",1)), CHAR(10),\'\'), CHAR(13),\'\'),\"/html/\",id,\"/<#if m??>${m}</#if>\") as url,\r\nREPLACE(REPLACE(TRIM(substring_index(app_url,\"\\n\",1)), CHAR(10),\'\'), CHAR(13),\'\') as host,\r\n</#if>\r\nCONCAT(\"templets/\",id,\"/\",<#if m??>CONCAT(app_style,\"/${m}\")<#else>app_style</#if>) as style <#-- 判断是否为手机端 -->\r\nfrom app where id = ${appId} limit 1', `sort` = 1 WHERE `id` = 7;
UPDATE `mdiy_tag_sql` SET `tag_id` = 7, `tag_sql` = 'SELECT \r\ncms_content.id as id,\r\nleft(content_title,${titlelen?default(40)}) as title,\r\ncontent_title as fulltitle,\r\ncontent_author as author, \r\ncontent_source as source, \r\ncontent_details as content,\r\ncategory_title as typetitle,\r\ncms_category.id as typeid,\r\n cms_category.category_img AS typelitpic,\r\n<#--动态链接-->\r\n<#if isDo?? && isDo>\r\nCONCAT(\"/${modelName}/list.do?typeid=\", cms_category.id) as typelink,\r\n<#else>\r\n(SELECT \"index.html\") as typelink,\r\n</#if>\r\ncms_content.content_img AS litpic,\r\n<#--内容页动态链接-->\r\n<#if isDo?? && isDo>\r\nCONCAT(\"/mcms/view.do?id=\", cms_content.id) as link,\r\n<#else>\r\ncontent_url AS link,\r\n</#if>\r\ncontent_datetime as date,\r\ncontent_description as descrip,\r\nCONCAT(\"<script type=\'text/javascript\' src=\'${url}/cms/content/\",cms_content.id,\"/hit.do\'></script>\") as hit,\r\ncontent_type as flag,\r\ncategory_title as typetitle,\r\n<#if tableName??>${tableName}.*,</#if>\r\ncontent_keyword as keyword\r\nFROM cms_content\r\nLEFT JOIN cms_category  ON \r\n<#--如果是栏目列表页没有文章id所以只取栏目id-->\r\n<#if column??&&column.id??&&!id??> \r\n cms_category.id=${column.id}\r\n<#else>\r\ncms_category.id = content_category_id\r\n</#if>\r\n<#--判断是否有自定义模型表-->\r\n<#if tableName??>left join ${tableName} on ${tableName}.link_id=cms_content.id</#if>\r\nWHERE \r\n cms_content.del=0\r\n<#if id??> and cms_content.id=${id}</#if>', `sort` = 1 WHERE `id` = 8;
UPDATE `mdiy_tag_sql` SET `tag_id` = 8, `tag_sql` = '<#assign select=\"(SELECT \'\')\"/>\r\n<#if orderby?? >\r\n      <#if orderby==\"date\"> \r\n	   <#assign  _orderby=\"content_datetime\">\r\n      <#elseif orderby==\"updatedate\">\r\n <#assign  _orderby=\"content_updatetime\">\r\n      <#elseif orderby==\"hit\"> \r\n	  <#assign  _orderby=\"content_hit\">\r\n      <#elseif orderby==\"sort\">\r\n	   <#assign  _orderby=\"content_sort\">\r\n      <#else><#assign  _orderby=\"cms_content.id\"></#if>\r\n   <#else>\r\n   <#assign  _orderby=\"cms_content.id\">\r\n  </#if>\r\n<#if (pageTag.preId) gt 0>\r\nSELECT \r\ncms_content.id as id,\r\nleft(content_title,${titlelen?default(40)}) as title,\r\ncontent_title as fulltitle,\r\ncontent_author as author, \r\ncontent_source as source, \r\ncontent_details as content,\r\ncategory.category_title as typename,\r\ncategory.category_id as typeid,\r\n(SELECT \"index.html\") as typelink,\r\ncontent_img as litpic,\r\n<#--内容页动态链接-->\r\n  <#if isDo?? && isDo>\r\n   CONCAT(\"/${modelName}/view.do?id=\", cms_content.id,\"&orderby=${_orderby}\",\"&order=${order!\'ASC\'}\",\"&typeid=${typeid}\") as link,\r\n  <#else>\r\n  CONCAT(category_path,\"/\",cms_content.id,\".html\") AS link,\r\n  </#if>\r\ncontent_datetime as date,\r\ncontent_description as descrip,\r\ncontent_hit as hit,\r\ncontent_type as flag,\r\ncontent_keyword as keyword \r\nFROM cms_content \r\nLEFT JOIN cms_category as category ON content_category_id=category.id \r\nWHERE cms_content.id=${pageTag.preId}\r\n<#else>\r\nSELECT \r\n${select} as id,\r\n${select} as title,\r\n${select} as fulltitle,\r\n${select} as author, \r\n${select} as source, \r\n${select} as content,\r\n${select} as typename,\r\n${select} as typeid,\r\n${select} as typelink,\r\n${select} as litpic,\r\n${select} as link,\r\n${select} as date,\r\n${select} as descrip,\r\n${select} as hit,\r\n${select} as flag,\r\n${select} as keyword FROM cms_content\r\n</#if>', `sort` = NULL WHERE `id` = 9;

ALTER TABLE `mdiy_model`
CHANGE COLUMN `model_app_id` `app_id`  int(11) NULL DEFAULT NULL COMMENT '应用编号' AFTER `model_json`;

ALTER TABLE `mdiy_dict`
ADD COLUMN `dict_enable`  varchar(11) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT '1' COMMENT '启用状态' AFTER `is_child`;

ALTER TABLE `cms_category` ADD COLUMN `leaf`  bigint(1) NULL DEFAULT NULL COMMENT '是否是叶子节点' AFTER `category_pinyin`;
ALTER TABLE `cms_category` ADD COLUMN `top_id`  bigint(20) NULL DEFAULT NULL COMMENT '顶级id' AFTER `leaf`;
ALTER TABLE `cms_category` MODIFY COLUMN `id`  bigint(20) UNSIGNED NOT NULL FIRST ;
ALTER TABLE `cms_content` MODIFY COLUMN `id`  bigint(20) UNSIGNED NOT NULL FIRST ;
ALTER TABLE `system_log` MODIFY COLUMN `id`  bigint(20) UNSIGNED NOT NULL FIRST ;

UPDATE `mdiy_tag_sql` SET `id`='5', `tag_id`='3', `tag_sql`='<#assign _typeid=\'\'/>\r\n<#assign _size=\'20\'/>\r\n<#if column?? && column.id?? && column.id?number gt 0>\r\n  <#assign  _typeid=\'${column.id}\'>\r\n</#if>\r\n<#if typeid??>\r\n  <#assign  _typeid=\'${typeid}\'>\r\n</#if>\r\n<#if size??>\r\n  <#assign  _size=\'${size}\'>\r\n</#if>\r\n<#if orderby?? >\r\n      <#if orderby==\'date\'> \r\n	   <#assign  _orderby=\'content_datetime\'>\r\n      <#elseif orderby==\'updatedate\'>\r\n <#assign  _orderby=\'content_updatetime\'>\r\n      <#elseif orderby==\'hit\'> \r\n	  <#assign  _orderby=\'content_hit\'>\r\n      <#elseif orderby==\'sort\'>\r\n	   <#assign  _orderby=\'content_sort\'>\r\n      <#else><#assign  _orderby=\'cms_content.id\'></#if>\r\n   <#else>\r\n   <#assign  _orderby=\'cms_content.id\'>\r\n  </#if>\r\nSELECT\r\n  cms_content.id AS id,\r\n  content_title AS title,\r\n  content_title AS fulltitle,\r\n  content_author AS author,\r\n  content_source AS source,\r\n  content_details AS content,\r\n  category.category_title AS typename,\r\n  category.id AS typeid,\r\n  category.category_img AS typelitpic,\r\n  <#--列表页动态链接-->\r\n  <#if isDo?? && isDo>\r\n  CONCAT(\'/${modelName}/list.do?typeid=\', category.category_id) as typelink,\r\n  <#else>\r\n  (SELECT \'index.html\') AS typelink,\r\n  </#if>\r\n  content_img AS litpic,\r\n  <#--内容页动态链接-->\r\n  <#if isDo?? && isDo>\r\n   CONCAT(\'/${modelName}/view.do?id=\', cms_content.id,\'&orderby=${_orderby}\',\'&order=${order!\'ASC\'}\',\'&typeid=${typeid}\') as \"link\",\r\n  <#else>\r\n\r\n  CONCAT(category.category_path,\'/\',cms_content.id,\'.html\') AS \"link\",\r\n  </#if>\r\n  content_datetime AS \"date\",<#if tableName??>${tableName}.*,</#if>\r\n  content_description AS descrip,\r\n  content_hit AS hit,\r\n  content_type AS flag,\r\n  category_title AS typetitle,\r\n  cms_content.content_keyword AS keyword \r\nFROM\r\n  cms_content\r\n  LEFT JOIN cms_category as category ON content_category_id = category.id\r\n  <#--判断是否有自定义模型表-->\r\n  <#if tableName??>LEFT JOIN ${tableName} ON ${tableName}.link_id=cms_content.id </#if>\r\nWHERE  \r\n  content_display=0 \r\n	and cms_content.del=0 \r\n  <#--根据站点编号查询-->\r\n  <#if appId?? >\r\n    and cms_content.app_id=${appId}\r\n	and cms_content.id>0\r\n  </#if>\r\n  <#--判断是否有搜索分类集合-->\r\n  <#if search??>\r\n		<#if search.categoryIds??>and FIND_IN_SET(category.id,\'${search.categoryIds}\')</#if>\r\n			<#--标题-->\r\n			<#if search.content_title??> and content_title like CONCAT(\'%\',\'${search.content_title}\',\'%\')</#if>\r\n			<#--作者-->\r\n			<#if search.content_author??> and content_author like CONCAT(\'%\',\'${search.content_author}\',\'%\')</#if>\r\n			<#--来源-->\r\n			<#if search.content_source??> and content_source like CONCAT(\'%\',\'${search.content_source}\',\'%\')</#if>\r\n			<#--属性-->\r\n			<#if search.content_type??> and  (\r\n			<#list search.content_type?split(\',\') as item>\r\n			<#if item?index gt 0> or</#if>\r\n			FIND_IN_SET(\'${item}\',cms_content.content_type)\r\n			</#list>)</#if>\r\n			<#--描述-->\r\n			<#if search.content_description??> and content_description like CONCAT(\'%\',\'${search.content_description}\',\'%\')</#if>\r\n			<#--关键字-->\r\n			<#if search.content_keyword??> and content_keyword like CONCAT(\'%\',\'${search.content_keyword}\',\'%\')</#if>\r\n			<#--内容-->\r\n			<#if search.content_details??> and content_details like CONCAT(\'%\',\'${search.content_details}\',\'%\')</#if>\r\n			\r\n<#--自定义顺序-->\r\n			<#if search.content_sort??> and content_sort=${search.content_sort}</#if>		\r\n<#--时间范围-->\r\n			<#if search.content_datetime_start??&&search.content_datetime_end??> and content_datetime between \'${search.content_datetime_start}\' and \'${search.content_datetime_end}\'</#if>\r\n  <#else><#--查询栏目-->\r\n    <#if _typeid?has_content> and (content_category_id=${_typeid} or content_category_id in \r\n  (select id FROM cms_category where cms_category.del=0 and FIND_IN_SET(${_typeid},CATEGORY_PARENT_ID))) </#if>\r\n </#if>\r\n  <#--标题-->\r\n  <#if content_title??> and content_title like CONCAT(\'%\',\'${content_title}\',\'%\')</#if>\r\n  <#--作者-->\r\n  <#if content_author??> and content_author like CONCAT(\'%\',\'${content_author}\',\'%\')</#if>\r\n  <#--来源-->\r\n  <#if content_source??> and content_source like CONCAT(\'%\',\'${content_source}\',\'%\')</#if>\r\n  <#--属性-->\r\n  <#if content_type??> and content_type like CONCAT(\'%\',\'${content_type}\',\'%\')</#if>\r\n  <#--描述-->\r\n  <#if content_description??> and content_description like CONCAT(\'%\',\'${content_description}\',\'%\')</#if>\r\n  <#--关键字-->\r\n  <#if content_keyword??> and content_keyword like CONCAT(\'%\',\'${content_keyword}\',\'%\')</#if>\r\n  <#--内容-->\r\n  <#if content_details??> and content_details like CONCAT(\'%\',\'${content_details}\',\'%\')</#if>\r\n  <#--自定义顺序-->\r\n  <#if content_sort??> and content_sort=${content_sort}</#if>\r\n  <#--自定义模型-->\r\n  <#if diyModel??> \r\n    <#list diyModel as dm>\r\n      and ${tableName}.${dm.key} like CONCAT(\'%\',\'${dm.value}\',\'%\') \r\n    </#list>\r\n  </#if>\r\n  <#--文章属性-->\r\n  <#if flag?? >\r\n			and(\r\n			<#list flag?split(\',\') as item>\r\n			<#if item?index gt 0> or</#if>\r\n			FIND_IN_SET(\'${item}\',cms_content.content_type)\r\n			</#list>)\r\n  </#if>\r\n  <#if noflag??>\r\n			and(\r\n			<#list noflag?split(\',\') as item>\r\n			<#if item?index gt 0> and</#if>\r\n			FIND_IN_SET(\'${item}\',cms_content.content_type)=0\r\n			</#list> or cms_content.content_type is null)\r\n  </#if>\r\n  <#--字段排序-->\r\n  <#if orderby?? >\r\n    ORDER BY \r\n      <#if orderby==\'date\'> content_datetime\r\n      <#elseif orderby==\'updatedate\'> content_updatetime\r\n      <#elseif orderby==\'hit\'> content_hit\r\n      <#elseif orderby==\'sort\'> content_sort\r\n      <#else>cms_content.id</#if>\r\n <#else>\r\n    ORDER BY   cms_content.id\r\n  </#if>\r\n  <#if order?? >\r\n      <#if order==\'desc\'> desc</#if>\r\n      <#if order==\'asc\'> asc</#if>\r\n  </#if>\r\n   LIMIT \r\n    <#--判断是否分页-->\r\n  <#if ispaging?? && (pageTag.pageNo)??>${((pageTag.pageNo-1)*_size?eval)?c},${_size?default(20)}\r\n  <#else>${_size?default(20)}</#if>', `sort`='1' WHERE (`id`='5');
UPDATE `mdiy_tag_sql` SET `id`='6', `tag_id`='4', `tag_sql`='<#assign _typeid=\'0\'/>\r\n<#if column?? && column.id?? && column.id?number gt 0>\r\n	<#assign  _typeid=\'${column.id}\'>\r\n	<#assign  selfid=\'${column.id}\'>\r\n</#if>\r\n<#if typeid??>\r\n	<#assign  _typeid=\'${typeid}\'>\r\n</#if>\r\nselect \r\n	id,\r\n	id as typeid,\r\n	category_title as typetitle,\r\n	<#--返回父id集合-->\r\n	category_parent_id as pids,\r\n	<#--动态链接-->\r\n	<#if isDo?? && isDo>\r\n	CONCAT(\'/${modelName}/list.do?typeid=\', id) as typelink,\r\n	<#else>\r\n		<#--栏目类型为链接-->\r\n		CONCAT(category_path,\'/index.html\') as typelink,\r\n	</#if>\r\n	category_keyword as typekeyword,\r\n	category_diy_url as typeurl,\r\n	category_flag as flag,\r\n category_parent_id as parentid,\r\ncategory_descrip as typedescrip,\r\n	category_img as typelitpic ,\r\n(select count(*) from cms_category c where c.category_id=id and c.del=0) as childsize\r\n	from cms_category  \r\n	where \r\n	cms_category.del=0 \r\n	<#--根据站点编号查询-->\r\n	<#if appId?? >\r\n		and cms_category.app_id=${appId}\r\n	</#if>\r\n	<#--栏目属性-->\r\n	  <#if flag?? >\r\n   and\r\n	(		<#list flag?split(\',\') as item>\r\n			<#if item?index gt 0> or</#if>\r\n			FIND_IN_SET(\'${item}\',category_flag)\r\n			</#list>)\r\n  </#if>\r\n	<#if noflag?? >\r\n      and\r\n			(\r\n			<#list noflag?split(\',\') as item>\r\n			<#if item?index gt 0> and</#if>\r\n			FIND_IN_SET(\'${item}\',category_flag)=0\r\n			</#list> or category_flag is null)\r\n	</#if>\r\n	<#--type默认son-->\r\n<#if !type??||!type?has_content>\r\n<#assign type=\'son\'/>\r\n</#if>\r\n<#if type?has_content>\r\n	<#--顶级栏目（单个）-->\r\n	<#if type==\'top\'>\r\n	<#if _typeid != \'0\'>\r\n		and (id = top_id or top_id = 0)\r\n		</#if>\r\n	<#elseif type==\'nav\'>\r\n		and(category_id=0 or category_id is null)\r\n	<#--同级栏目（多个）-->\r\n	<#elseif type==\'level\'>\r\n		and\r\n		<#if _typeid?has_content>\r\n		 category_id=(select category_id from cms_category where id=${_typeid})\r\n		<#else>\r\n		 1=1\r\n		</#if>\r\n  	<#--当前栏目（单个）-->\r\n	<#elseif type==\'self\'>\r\n		 and \r\n		 <#if _typeid?has_content>\r\n		  id=${_typeid}\r\n		 <#else>\r\n		 1=1\r\n		 </#if>\r\n	<#--当前栏目的所属栏目（多个）-->\r\n	<#elseif type==\'path\'>\r\n			and \r\n		 <#if _typeid?has_content>\r\n		   id in (<#if column?? && column.categoryParentId??>${column.categoryParentId},</#if>${_typeid})\r\n		 <#else>\r\n		  1=1\r\n		 </#if>\r\n	<#--子栏目（多个）-->\r\n	<#elseif type==\'son\'>\r\n			and \r\n		 <#if _typeid?has_content>\r\n		  category_id=${_typeid}\r\n		 <#else>\r\n		  1=1\r\n		 </#if>\r\n		 <#--上一级栏目没有则取当前栏目（单个）-->\r\n	<#elseif type==\'parent\'>\r\n			and \r\n		 <#if _typeid?has_content>\r\n		   <#if column?? && column.categoryId??>\r\n				id=${column.categoryId}\r\n			 <#else>\r\n			  id=${_typeid}\r\n			 </#if>\r\n		 <#else>\r\n		  1=1\r\n	</#if>\r\n	</#if>\r\n<#else> <#--默认顶级栏目-->\r\n	 and\r\n	<#if _typeid?has_content>\r\n	 id=${_typeid}\r\n	<#else>\r\n	 (category_id=0 or category_id is null)\r\n	</#if>\r\n</#if>\r\n<#--字段排序-->\r\n  <#if orderby?? >\r\n    ORDER BY \r\n      <#if orderby==\'date\'> category_datetime\r\n      <#elseif orderby==\'sort\'> category_sort\r\n      <#else>cms_content.id</#if>\r\n\r\n  </#if>\r\n  <#if order?? >\r\n      <#if order==\'desc\'> desc</#if>\r\n      <#if order==\'asc\'> asc</#if>\r\n  </#if>', `sort`='1' WHERE (`id`='6');
UPDATE `mdiy_tag_sql` SET `id`='7', `tag_id`='5', `tag_sql`='select \r\nAPP_NAME as name,\r\napp_logo as logo ,\r\napp_keyword as keyword,\r\napp_description as descrip,\r\napp_copyright as copyright,\r\n<#--动态解析 -->\r\n<#if isDo?? && isDo>\r\nCONCAT(\'${url}\',\'/${html}/\',id) as url,\r\n\'${url}\' as host,\r\n<#--使用地址栏的域名 -->\r\n<#elseif url??>\r\nCONCAT(\'${url}\',\'/${html}/\',id,\'/<#if m??>${m}</#if>\') as url,\r\n\'${url}\' as host,\r\n<#else>\r\nCONCAT(REPLACE(REPLACE(TRIM(substring_index(app_url,\'\\n\',1)), CHAR(10),\'\'), CHAR(13),\'\'),\'/html/\',id,\'/<#if m??>${m}</#if>\') as url,\r\nREPLACE(REPLACE(TRIM(substring_index(app_url,\'\\n\',1)), CHAR(10),\'\'), CHAR(13),\'\') as host,\r\n</#if>\r\nCONCAT(\'templets/\',id,\'/\',<#if m??>CONCAT(app_style,\'/${m}\')<#else>app_style</#if>) as \"style\" <#-- 判断是否为手机端 -->\r\nfrom app where id = ${appId} limit 1', `sort`='1' WHERE (`id`='7');
UPDATE `mdiy_tag_sql` SET `id`='8', `tag_id`='7', `tag_sql`='SELECT \r\ncms_content.id as id,\r\nleft(content_title,${titlelen?default(40)}) as title,\r\ncontent_title as fulltitle,\r\ncontent_author as author, \r\ncontent_source as source, \r\ncontent_details as content,\r\ncategory_title as typetitle,\r\ncms_category.id as typeid,\r\n cms_category.category_img AS typelitpic,\r\n<#--动态链接-->\r\n<#if isDo?? && isDo>\r\nCONCAT(\'/${modelName}/list.do?typeid=\', cms_category.id) as typelink,\r\n<#else>\r\n(SELECT \'index.html\') as typelink,\r\n</#if>\r\ncms_content.content_img AS litpic,\r\n<#--内容页动态链接-->\r\n<#if isDo?? && isDo>\r\nCONCAT(\'/mcms/view.do?id=\', cms_content.id) as \"link\",\r\n<#else>\r\ncontent_url AS \"link\",\r\n</#if>\r\ncontent_datetime as \"date\",\r\ncontent_description as descrip,\r\nCONCAT(\'<script type=\"text/javascript\" src=\"${url}/cms/content/\',cms_content.id,\'/hit.do\"></script>\') as hit,\r\ncontent_type as flag,\r\ncategory_title as typetitle,\r\n<#if tableName??>${tableName}.*,</#if>\r\ncontent_keyword as keyword\r\nFROM cms_content\r\nLEFT JOIN cms_category  ON \r\n<#--如果是栏目列表页没有文章id所以只取栏目id-->\r\n<#if column??&&column.id??&&!id??> \r\n cms_category.id=${column.id}\r\n<#else>\r\ncms_category.id = content_category_id\r\n</#if>\r\n<#--判断是否有自定义模型表-->\r\n<#if tableName??>left join ${tableName} on ${tableName}.link_id=cms_content.id</#if>\r\nWHERE \r\n cms_content.del=0\r\n<#if id??> and cms_content.id=${id}</#if>', `sort`='1' WHERE (`id`='8');
UPDATE `mdiy_tag_sql` SET `id`='9', `tag_id`='8', `tag_sql`='<#assign select=\"(SELECT \'\')\"/>\r\n<#if orderby?? >\r\n      <#if orderby==\"date\"> \r\n	   <#assign  _orderby=\"content_datetime\">\r\n      <#elseif orderby==\"updatedate\">\r\n <#assign  _orderby=\"content_updatetime\">\r\n      <#elseif orderby==\"hit\"> \r\n	  <#assign  _orderby=\"content_hit\">\r\n      <#elseif orderby==\"sort\">\r\n	   <#assign  _orderby=\"content_sort\">\r\n      <#else><#assign  _orderby=\"cms_content.id\"></#if>\r\n   <#else>\r\n   <#assign  _orderby=\"cms_content.id\">\r\n  </#if>\r\n<#if pageTag.preId??>\r\nSELECT \r\ncms_content.id as id,\r\nleft(content_title,${titlelen?default(40)}) as title,\r\ncontent_title as fulltitle,\r\ncontent_author as author, \r\ncontent_source as source, \r\ncontent_details as content,\r\ncategory.category_title as typename,\r\ncategory.category_id as typeid,\r\n(SELECT \'index.html\') as typelink,\r\ncontent_img as litpic,\r\n<#--内容页动态链接-->\r\n  <#if isDo?? && isDo>\r\n   CONCAT(\'/${modelName}/view.do?id=\', cms_content.id,\'&orderby=${_orderby}\',\'&order=${order!\'ASC\'}\',\'&typeid=${typeid}\') as \"link\",\r\n  <#else>\r\n  CONCAT(category_path,\'/\',cms_content.id,\'.html\') AS \"link\",\r\n  </#if>\r\ncontent_datetime as \"date\",\r\ncontent_description as descrip,\r\ncontent_hit as hit,\r\ncontent_type as flag,\r\ncontent_keyword as keyword \r\nFROM cms_content \r\nLEFT JOIN cms_category as category ON content_category_id=category.id \r\nWHERE cms_content.id=${pageTag.preId}\r\n<#else>\r\nSELECT \r\n${select} as id,\r\n${select} as title,\r\n${select} as fulltitle,\r\n${select} as author, \r\n${select} as source, \r\n${select} as content,\r\n${select} as typename,\r\n${select} as typeid,\r\n${select} as typelink,\r\n${select} as litpic,\r\n${select} as \"link\",\r\n${select} as \"date\",\r\n${select} as descrip,\r\n${select} as hit,\r\n${select} as flag,\r\n${select} as keyword FROM cms_content\r\n</#if>', `sort`=NULL WHERE (`id`='9');
UPDATE `mdiy_tag_sql` SET `id`='10', `tag_id`='9', `tag_sql`='  select\r\n	<#if !(pageTag.indexUrl??)>\r\n	<#--判断是否有栏目对象，用于搜索不传栏目-->\r\n	<#if column??>\r\n		<#assign path=column.categoryPath/>\r\n	<#else>\r\n		<#assign path=\"\"/>\r\n	</#if>\r\n  <#--总记录数、总页数-->\r\n	(SELECT ${pageTag.total}) as \"total\",\r\n	<#--记录总数-->\r\n	(SELECT ${pageTag.size}) as \"rcount\",\r\n	<#--当前页码-->\r\n	(SELECT ${pageTag.pageNo}) as \"cur\",\r\n	<#--首页-->\r\n  CONCAT(\'${path}\', \'/index.html\') as \"index\",\r\n	<#--上一页-->\r\n	<#if (pageTag.pageNo?eval-1) gt 1>\r\n	CONCAT(\'${path}\',\'/list-${pageTag.pageNo?eval-1}.html\') as \"pre\",\r\n	<#else>\r\n	CONCAT(\'${path}\',\'/index.html\') as \"pre\",\r\n	</#if>\r\n	<#--下一页-->\r\n	<#if pageTag.total==1>\r\n		CONCAT(\'${path}\', \'/index.html\') as \"next\",\r\n		CONCAT(\'${path}\', \'/index.html\') as \"last\"\r\n	<#else>\r\n		<#if pageTag.pageNo?eval gte pageTag.total>\r\n		CONCAT(\'${path}\',\'/list-${pageTag.total}.html\') as \"next\",\r\n		<#else>\r\n		CONCAT(\'${path}\',\'/list-${pageTag.pageNo?eval+1}.html\') as \"next\",\r\n		</#if>\r\n		<#--最后一页-->\r\n		CONCAT(\'${path}\',\'/list-${pageTag.total}.html\') as \"last\"\r\n		</#if>\r\n<#else><#--判断是否是搜索页面-->\r\n \'${pageTag.indexUrl}\' as \"index\",\'${pageTag.lastUrl}\' as \"last\",\'${pageTag.preUrl}\' as \"pre\",\'${pageTag.nextUrl}\' as \"next\",\'${pageTag.total}\' as \"total\",\'${pageTag.size}\' as \"rcount\",\'${pageTag.pageNo}\' as \"cur\"\r\n</#if>', `sort`=NULL WHERE (`id`='10');
UPDATE `mdiy_tag_sql` SET `id`='11', `tag_id`='10', `tag_sql`='<#assign select=\"(SELECT \'\')\"/>\r\n<#if orderby?? >\r\n      <#if orderby==\"date\"> \r\n	   <#assign  _orderby=\"content_datetime\">\r\n      <#elseif orderby==\"updatedate\">\r\n <#assign  _orderby=\"content_updatetime\">\r\n      <#elseif orderby==\"hit\"> \r\n	  <#assign  _orderby=\"content_hit\">\r\n      <#elseif orderby==\"sort\">\r\n	   <#assign  _orderby=\"content_sort\">\r\n      <#else><#assign  _orderby=\"cms_content.id\"></#if>\r\n   <#else>\r\n   <#assign  _orderby=\"cms_content.id\">\r\n  </#if>\r\n<#if pageTag.nextId??>\r\nSELECT \r\ncms_content.id as id,\r\nleft(content_title,${titlelen?default(40)}) as title,\r\ncontent_title as fulltitle,\r\ncontent_author as author, \r\ncontent_source as source, \r\ncontent_details as content,\r\ncategory.category_title as typename,\r\ncategory.category_id as typeid,\r\n(SELECT \'index.html\') as typelink,\r\ncontent_img as litpic,\r\n<#--内容页动态链接-->\r\n  <#if isDo?? && isDo>\r\n   CONCAT(\'/${modelName}/view.do?id=\', cms_content.id,\'&orderby=${_orderby}\',\'&order=${order!\'ASC\'}\',\'&typeid=${typeid}\') as \"link\",\r\n  <#else>\r\n  CONCAT(category_path,\'/\',cms_content.id,\'.html\') AS \"link\",\r\n  </#if>\r\ncontent_datetime as \"date\",\r\ncontent_description as descrip,\r\ncontent_hit as hit,\r\ncontent_type as flag,\r\ncontent_keyword as keyword \r\nFROM cms_content \r\nLEFT JOIN cms_category as category ON content_category_id=category.id \r\nWHERE cms_content.id=${pageTag.nextId}\r\n<#else>\r\nSELECT \r\n${select} as id,\r\n${select} as title,\r\n${select} as fulltitle,\r\n${select} as author, \r\n${select} as source, \r\n${select} as content,\r\n${select} as typename,\r\n${select} as typeid,\r\n${select} as typelink,\r\n${select} as litpic,\r\n${select} as \"link\",\r\n${select} as \"date\",\r\n${select} as descrip,\r\n${select} as hit,\r\n${select} as flag,\r\n${select} as keyword FROM cms_content\r\n</#if>', `sort`=NULL WHERE (`id`='11');
