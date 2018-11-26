class ArticlesController < ApplicationController
  def index
    @articles = Article.all

    # Testing logging output
    logger.debug 'Logging Test: debug'
    logger.info  'Logging Test: info'
    logger.warn  'Logging Test: warn'

    # Testing tagged logging
    # logger.tagged('This is a tag') { logger.debug('This is a debug statement') }
  end
end
