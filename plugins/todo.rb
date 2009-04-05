# encoding: utf-8
require "enumerator"

FBSDBot::Plugin.define('todo') {
  author "jp_tix"
  version "0.0.1"
  commands %w{todo todos}

  class TODOItem
    attr_reader :text
    def initialize(text)
      @text = text
      @done = false
      @id   = Digest::SHA1.hexdigest(@text + Time.now.to_s)
    end

    def done?
      @done
    end

    def done!
      @done = true
    end


  end


  class TODOApp
    def initialize
      @todos = {}
    end

    def save(filename)
      open(filename, "w") { |io| YAML.dump(@todos, io) } unless @todos.empty?
    end

    def load(filename)
      @todos = YAML.load_file(filename)
    end

    def add(nick, text)
      if @todos[nick].nil?
        @todos[nick] = [TODOItem.new(text)]
      else
        @todos[nick] << TODOItem.new(text)
      end
    end

    def del(nick, id)
      if @todos[nick].nil?
        return
      else
        @todos[nick].delete_at(id - 1)
      end
    end

    def list(nick)
      if @todos[nick].nil?
        return []
      else
        @todos[nick].select { |t| t.done? == false }
      end
    end

  end

  @td = TODOApp.new
  @file = 'todo.yaml'
  @started = false

  def on_join(action)
    return if @started
    if File.exist?(@file)
      @td.load(@file)
      puts "Loaded TODO-file."
    else
      puts "No TODO-file found @ #{@file}"
    end
    @started = true
  end

  def on_cmd_todo(action)
    if action.message =~ (/del (\d+)/)
      @td.del(action.user.nick, $1.to_i) == nil ? action.reply("Not found.") : action.reply("Ok, deleted todo.")
    else
      @td.add(action.user.nick, action.message)
      action.reply "Todo added."
    end
  end

  def on_cmd_todos(action)
    todo_string = @td.list(action.user.nick).enum_with_index.map { |todo, i| "%y#{i+1}%n: #{todo.text}" }.join(" %r|%n ")
    if todo_string.empty?
      action.reply "Your TODO list is empty."
    else
      action.reply "TODOs: " + todo_string
    end
  end

  def on_shutdown
    @td.save(@file)
  end


}
