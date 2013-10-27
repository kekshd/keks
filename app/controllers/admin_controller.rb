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

  private
  def tree_category(cat)
    dot = cat.dot

    cat.questions.each do |q|
      dot << tree_question(q)
      dot << "#{cat.dot_id} -> #{q.dot_id};"
    end
    return dot
  end

  def tree_question(quest)
    dot = quest.dot

    dot << quest.dot_hints

    quest.answers.each do |a|
      dot << a.dot
      dot << "#{quest.dot_id} -> #{a.dot_id};\n"

      a.categories.each do |cc|
        dot << tree_category(cc)
        dot << "#{a.dot_id} -> #{cc.dot_id};\n"
      end


      a.questions.each do |qq|
        dot << tree_question(qq)
        dot << "#{a.dot_id} -> #{qq.dot_id};\n"
      end
    end

    return dot
  end
end
