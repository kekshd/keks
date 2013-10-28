# encoding: utf-8

class AdminController < ApplicationController
  before_filter :require_admin, :except => [:tree, :export]
  before_filter :require_admin_or_reviewer

  def overview
  end

  def tree
    dot = ""
    Category.root_categories.each do |c|
      dot << tree_category(c)
    end

    fn = "keks-tree-#{Date.today}"

    respond_to do |format|
      format.dot { send_data %(digraph graphname { rankdir=LR; #{dot} }), filename: "#{fn}.dot"}
      format.svgz { send_data get_dot_svgz(dot), filename: "#{fn}.svgz" }
    end
  end

  def export
  end

  def export_question
    get_question
    render partial: "export_question", locals: { question: @question, max_depth: 10 }
  end

  private

  include DotTools

  def tree_category(cat)
    cat.dot + dot_iter_questions(cat)
  end

  def tree_question(quest)
    dot = quest.dot

    dot << quest.dot_hints

    quest.answers.each do |a|
      dot << dot_link_to(quest, a)

      a.categories.each do |cc|
        dot << tree_category(cc)
        dot << dot_link(a, cc)
      end

      dot << dot_iter_questions(a)
    end

    return dot
  end

  def dot_iter_questions(from)
    dot = ""
    from.questions.each do |qq|
      dot << tree_question(qq)
      dot << dot_link(from, qq)
    end
    dot
  end
end
