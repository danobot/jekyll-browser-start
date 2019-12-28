# Jekyll-to-Ghost
#
# This Jekyll plugin exports your Markdown posts into a format that can be easily imported by Ghost.
# http://ghost.org
#
# Author: Rose Lin (updated based on Matt Harzewski's work)
# Copyright: Copyright 2013 Matt Harzewski
# License: GPLv2 or later
# Version: 1.0.1


require 'json'


module Jekyll



	class GhostPage < StaticFile

		def initialize(site, base, dir, name, contents)
			@site = site
			@base = base
			@dir  = dir
			@name = name
			@contents = contents
		end

		def write(dest)
			File.open(File.join(@site.config['destination'], 'ghost_export.json'), 'w') do |f|
				f.write(JSON.pretty_generate(@contents))
			end
			true
		end

	end



	class JsonFileGenerator < Generator


		safe true


		def initialize(site)
			super
			@tags = []
			@postTagMap = Hash.new
		end


		def generate(site)

			converter = site.find_converter_instance(Jekyll::Converters::Markdown)
			ex_posts = []
			id = 0

			site.posts.docs.each do |post|

				timestamp =Time.now.to_i
				# timestamp = post.date.to_i * 1000
				author_id = 1
                
         
								# "{\"version\":\"0.3.1\",\"atoms\":[],\"cards\":[[\"markdown\",{\"markdown\":\"Fds\"}]],\"markups\":[],\"sections\":[[10,0],[1,\"p\",[]]]}"
				mobiledoc = generate_mobileloc(post) ;
				# Jekyll.logger.info post.to_json
				ex_post = {
					"id" => id,
					"title" => post.data['title'],
					"slug" => post.data['slug'],
					# "markdown" => post.content,
					# "mobiledoc" => mobiledoc,
					"mobiledoc" => mobiledoc.to_json.to_s,
					# "html" => converter.convert(post.content),
					"feature_image" => processUrl(post.data['image']),
					"featured" => 0,
					"page" => 0,
					"status" => "published",
					"published_at" => timestamp,
					"published_by" => 1,
					"meta_title" => post.data['title'],
					"meta_description" => post.data['excerpt'],
					"author_id" => author_id,
					"created_at" => timestamp,
					"created_by" => 1,
					"updated_at" => timestamp,
					"updated_by" => 1
				}

				ex_posts.push(ex_post)

				self.process_tags(id, post.data['tags'], post.data['categories'])
				id += 1
			end

			export_object = {
				"meta" => {
					"exported_on" => Time.now.to_i * 1000,
					"version" => "2.14.0"
				},
				"data" => {
					"posts" => ex_posts,
					"tags" => self.tag_objects,
					"posts_tags" => self.posts_tag_objects,
                    "users" => self.author_objects(site)
                    # TODO: add roles_users
				}
			}

			site.static_files << GhostPage.new(site, site.source, site.config['destination'], 'ghost_export.json', export_object)

		end
		def generate_mobileloc(post) 
			cards = []
			content = post.content
			slug = post.data['slug']
			Jekyll.logger.info post.data['slug']

			# find all occurances of link {% post_url rails/2016-12-15-carrierwave-upload-to-gcp %}
			# re = "/{% post_url (.*) %}/mU"
			re = /(\{\%\s?post_url\s?(.*)\s?%\})/

			str = content
			Jekyll.logger.info "Generating Mobileloc"
			# Print the match result
			str.scan(re) do |match|
				Jekyll.logger.info match
				
				new_link = gen_new_link(match[1])
				Jekyll.logger.info "new link\t\t" + new_link + "\t\t" + match[0] 
				str = str.gsub(match[0], new_link)

			end


			# find all image tag references
			re = /(\!\[(.*?)\]\(\{\{(.*?)\}\}\))/

			str = content
			Jekyll.logger.info "Generating Mobileloc"
			# Print the match result
			last_one = str
			str.scan(re) do |match|
				Jekyll.logger.info "============================ Processing image " + match[0].gsub('\n','') + " ==============================="
				Jekyll.logger.info "Previous last_one\t\t" + last_one.gsub('\n','')
				Jekyll.logger.info "------------------------------------------------------------------------------------------------------------"
				
				# split by image tag ![Caption]({{ "/assets/img/image.jpg" | relative_url }})

				if last_one
					split =	last_one.split( match[0]) # [before, after]
					# Jekyll.logger.info split
					Jekyll.logger.info "Split Before\t\t" + split[0].gsub('\n','')
					
					cards << add_markdown_card(split[0])

					Jekyll.logger.info "Split After\t\t" + split[1].to_s.gsub('\n','')
					cards << add_image_card(match[1], match[2])
					last_one = split[1]
				else
					Jekyll.logger.info "The image was the last bit of text."
				end
			end
			if last_one
				cards << add_markdown_card(last_one)
			end

			sections = generate_sections(cards)
			return {
				"version" => '0.3.1',
				"atoms" => [],
				# "cards" => [['html', { "html" => converter.convert(post.content)}]],
				"cards" => cards,
				"markups" => [],
				"sections" => sections
		}
		end
		def generate_sections(cards)
			sec = []
			cards.each.with_index { |val,index| 
				sec << [10, index]
			
			}
			sec << [1, "p", []]
			return sec
		end
		def add_markdown_card(md)
			return ['markdown', { "markdown" => md}]
		end

		def add_image_card(caption, url)
			Jekyll.logger.info url
			theUrl = processUrl(url)
			Jekyll.logger.info theUrl
			return ["image", {"src" => theUrl, "caption" => caption}]
		end
		def processUrl(url)
			return url.split("|")[0].to_s.gsub('"','').gsub('/assets/img', '/content/images').strip

		end
		def gen_new_link(filename)

			# remove date
			filename.slice!(0, 11)
			return '/' + filename

		end

		def process_tags(postId, tags, categories)
			unique_tags = tags | categories
			unique_tags = unique_tags.map do |t|

				t = t.to_s.chomp(",")
				t = t.downcase
			end
			@tags = unique_tags | @tags

			@postTagMap[postId] = unique_tags
		end


		def tag_objects
			tag_array = []
			@tags.each do |tag|
				tag_array.push({
					"id" => tag_array.size,
					"name" => tag,
					"slug" => tag.downcase,
					"description" => ""
				})
			end
			return tag_array
		end

		def posts_tag_objects
			posts_tag_array = []
			@postTagMap.each do |post, tags|
				tags.each do |tag|
					posts_tag_array.push({
										"id" => (posts_tag_array.size + 1),
										"post_id" => post,
										"tag_id" => @tags.index(tag)
										})
				end
			end
			return posts_tag_array
		end
        
        def author_objects(site)
			author_array = []
            
            # check if the site has any author information
            is_author_set = false
            if site.data.key?('authors')
                is_author_set = true
            end
            
            if is_author_set then
                all_users = site.data['authors'].keys
                
                for u in all_users do
                    author = site.data['authors'][u]
                    
                    ex_author = {
                        "id" => u,
                        "name" => author['name'],
                        "slug" => nil,
                        "email" => author['email'] ? author['email'] : nil,
                        "profile_image" => author['profile_image'] ? author['profile_image'] : nil,
                        "cover_image" => author['cover_image'] ? author['cover_image'] : nil,
                        "bio" => author['bio'] ? author['bio'] : nil,
                        "website" => author['website'] ? author['website'] : nil,
                        "location" => author['location'] ? author['location'] : nil,
                        "accessibility" => author['accessibility'] ? author['accessibility'] : nil,
                        "meta_title" => author['meta_title'] ? author['meta_title'] : nil,
                        "meta_description" => author['meta_description'] ? author['meta_description'] : nil,
                        "created_at" => Time.now.to_i * 1000,
                        "created_by" => 1,
                        "updated_at" => Time.now.to_i * 1000,
                        "updated_by" => 1
                    }

                    author_array.push(ex_author)

                end
            end
            
            # handle cases when there is no author information provided from the _data folder
            default_author = {
                "id" => 1,
                "name" => "default", # Change this to your name
                "slug" => nil, # Change this to your slug, or keep it nil. Ghost will automatically assign one if nil
                "email" => "example@test.com", # Change this to your email
                "profile_image" => nil, # Change this to your profile image url
                "cover_image" =>  nil, # Change this to your cover image url
                "bio" => nil, # Change this to your bio
                "website" => "https://ghost.org/", # Change this to your website
                "location" => nil, # Change this to your location
                "accessibility" => nil, # Change this to your accessibility
                "meta_title" => nil, # Change this to your meta title (optional)
                "meta_description" => nil, # Change this to your meta description (optional)
                "created_at" => Time.now.to_i * 1000,
                "created_by" => 1,
                "updated_at" => Time.now.to_i * 1000,
                "updated_by" => 1
            }
                    
            author_array.push(default_author)
            
			return author_array
		end

	end



end