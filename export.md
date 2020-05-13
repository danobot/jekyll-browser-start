---
permalink: export.xml
layout: none
---
<?xml version="1.0" encoding="UTF-8"?>
<xml>
    <posts>
    {% for post in site.posts %}
        {% assign tags = post.tags | split: ' ' %}

      <item>
        <title>{{post.title}}</title>
        <link>{% if post.link %}{{ post.link }}{% else %}{{ site.url }}{{ post.url }}{% endif %}</link>
        <pubDate>{{ post.date | date_to_xmlschema }}</pubDate>
        <creator>{{ site.owner.name }}</creator>
        <guid/>
        <description>{{ post.description }}</description>
        <content_encoded>{{ post.content | markdown}}</content_encoded>
        <content_raw>{{ post.content}}</content_raw>
        <post_id>{{ post.id }}</post_id>
        <post_date>{{ post.date | date_to_xmlschema }}</post_date>
        <post_date_gmt>{{ post.date | date_to_xmlschema }}</post_date_gmt>
        <cats>
        {% for tag in tags %}
          <category domain="post_tag" nicename="{{tag | slugify}}">{{tag}}</category>
        {% endfor %}
        </cats>

        <status>publish</status>
        <post_parent>0</post_parent>
        <menu_order>0</menu_order>
        <post_type>post</post_type>
      </item>
    {% endfor %}
    </posts>

</xml>