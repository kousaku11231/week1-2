# frozen_string_literal: true

# ゲーム進行 メインの流れ
module GameMasterFlow
  def first_part
    # プレイヤーとディーラーのスコアを定義
    @player_score = Score.new
    @dealer_score = Score.new
    print 'ブラックジャックを開始します'
    gets
    # プレイヤーがカードを引く
    player_deal_card
    player_deal_card
  end

  def second_part
    # ディーラーが一枚目のカードを引く 二枚目は公開しない
    dealer_deal_card(true)
    dealer_deal_card(false)
    # カードを追加するかどうか尋ねる
    player_add_card_yes_or_no
    # ディーラーの二枚目のカードと得点を公開
    report_a
  end

  def third_part
    # ディーラーがカードを追加
    dealer_add_card
    # 得点を発表
    report_b
    # 結果発表
    Judge.new(@player_score.score, @dealer_score.score)
  end
end

# ゲーム進行 メソッド
module GameMasterMethod
  # プレイヤーがカードを引く
  def player_deal_card
    @player = DealCards.new
    print "あなたの引いたカードは#{@player.card}です"
    gets
    @card_to_numbers = CardsToNumbers.new(@player.cards_number, @player_score.score)
    @player_score.add_score(@player_score.score, @card_to_numbers.number)
  end

  # ディーラーがカードを引く
  def dealer_deal_card(open)
    @dealer = DealCards.new
    if open
      print "ディーラーの引いたカードは#{@dealer.card}です"
    else
      print 'ディーラーの引いた二枚目のカードはわかりません。'
    end
    gets
    @card_to_numbers = CardsToNumbers.new(@dealer.cards_number, @dealer_score.score)
    @dealer_score.add_score(@dealer_score.score, @card_to_numbers.number)
  end

  # 途中経過を発表
  def report_a
    print "ディーラーの二枚目のカードは#{@dealer.card}でした。"
    gets
    print "ディーラーの現在の得点は#{@dealer_score.score}です。"
    gets
  end

  # カードを追加するかどうか尋ねる
  def player_add_card_yes_or_no
    print "あなたの現在の得点は#{@player_score.score}です。カードを引きますか？(Y/N)"
    case gets.chomp
    when 'Y', 'y'
      player_add_card_yes
    when 'N', 'n'
      nil
    else player_add_card_else
    end
  end

  def player_add_card_yes
    player_deal_card
    # バーストを判断
    Bust.new(true, @player_score.score)
    player_add_card_yes_or_no
  end

  def player_add_card_else
    print 'YかNを入力してください'
    gets
    player_add_card_yes_or_no
  end

  # 途中経過を報告
  def report_b
    print "あなたの得点は#{@player_score.score}です"
    gets
    print "ディーラーの得点は#{@dealer_score.score}です"
    gets
  end

  # ディーラーの得点が17以下ならカードを追加
  def dealer_add_card
    return unless @dealer_score.score < 17

    dealer_deal_card(true)
    Bust.new(false, @dealer_score.score)
    dealer_add_card
  end
end

# ブラックジャックの進行
class BlackJack
  include GameMasterFlow
  include GameMasterMethod
  def initialize
    # # プレイヤーとディーラーのスコアを定義
    # # プレイヤーがカードを引く
    first_part
    # # ディーラーが一枚目のカードを引く 二枚目は公開しない
    # # カードを追加するかどうか尋ねる
    # # ディーラーの二枚目のカードと得点を公開
    second_part
    # ディーラーがカードを追加
    # 得点を発表
    # 結果発表
    third_part
  end
end

# カードを引く
class DealCards
  attr_reader :card, :cards_number

  def initialize
    @suit = %w[ハート ダイヤ クローバー スペード].sample
    @cards_number = %w[A 2 3 4 5 6 7 8 9 10 J Q K].sample
    @card = "#{@suit}の#{@cards_number}"
  end
end

# Aを1or11に、J,Q,Kを10に変換
class CardsToNumbers
  attr_reader :number

  def initialize(cards_number, score)
    @number = if %w[J Q K].include?(cards_number)
                10
              elsif cards_number == 'A'
                if score >= 11
                  1
                else
                  11
                end
              else
                cards_number.to_i
              end
  end
end

# スコア計算
class Score
  attr_reader :score

  def initialize
    @score = 0
  end

  def add_score(score, add_score)
    @score = score
    @score += add_score
  end
end

# バーストを判断 playerがtureならプレイヤーのバーストを判断
class Bust
  def initialize(player, score)
    return unless score > 21

    if player
      print 'あなたはバーストしました。ディーラーの勝ちです'
    else
      print 'ディーラーがバーストしました。あなたの勝ちです!'
    end
    exit
  end
end

# 結果発表
class Judge
  def initialize(player_score, dealer_score)
    if player_score > dealer_score
      print 'あなたの勝ちです！'
    elsif player_score < dealer_score
      print 'ディーラーの勝ちです'
    else
      print '引き分けです'
    end
    exit
  end
end

BlackJack.new
