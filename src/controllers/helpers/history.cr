module Wikicr::Helpers::History
  class HistoryStorage < Array(String)
    SEPARATOR    = "|"
    KEEP_ENTRIES = 6

    @app : ApplicationController

    def initialize(@app)
      super(1)
    end

    def parse(history_string : String) : self
      history_string.split(SEPARATOR).each do |page|
        push(page)
      end

      self
    end

    def <<(page : Wikicr::Page) : self
      push(page.real_url)
      pop_amount = size - KEEP_ENTRIES
      pop(pop_amount) if pop_amount > 0

      @app.set_cookie name: "user.history", value: to_s, expires: 14.days.from_now

      self
    end

    def to_s
      join(SEPARATOR)
    end
  end

  def history : HistoryStorage
    current_history = session.string?("user.history")
    if current_history
      HistoryStorage.new(self).parse(current_history)
    else
      HistoryStorage.new(self)
    end
  end
end
