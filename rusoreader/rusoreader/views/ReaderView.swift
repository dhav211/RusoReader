import UIKit

class ReaderView: UIViewController {
    var text = NSMutableAttributedString(string: """
    Может быть, я когда-нибудь прилетела с другой планеты? Давно. И забыла об этом. Или меня родители пронесли контрабандой. В животе. Мне часто говорят, что я инопланетянка, но никто не может объяснить, в чем это проявляется.
    
    Видимо, поэтому я несколько десоциализирована. Я не понимаю многих поступков людей, которые меня окружают, а они в свою очередь настороженно относятся ко мне, несмотря на ту симпатию, которую мы друг к другу испытываем в большинстве случаев. Поэтому я почти всегда одинока, несмотря на большое количество замечательных, дорогих мне людей, меня окружающих. Видимо, я с очень далекой планеты, поэтому мои земляки редки на Земле. Я мечтаю встретить своего сопланетника. Наверное, он так же, как я, бродит по планете Земля, грустит и мечтает встретить меня. Маленький мой, как же нам найти Друг друга? Мне немножко страшно, вдруг этого никогда не произойдет.
    
    — Да, глупость сморозил. Вкалывать нам еще и вкалывать. А о пенсии я только мечтаю. Ну должна же быть у человека мечта! Без мечты и жизнь не в жизнь.

    «Романтик!» — подумал Матвей. Впрочем, он и сам был идеалистом, иначе не служил бы в отделе № 7 Особого управления МВД РФ. Других людей «семерка» отторгала.

    А еще он никак не мог совладать со своими чувствами. Чтобы начальник признал свою неправоту? Где найти такого начальника? Прошу любить и жаловать: Николай Семенович Ухов! Уникальный экземпляр. Ну как такого не любить, не уважать? Права Любаша. Вот он какой, наш Старик!

    Полковник повернулся к верстаку, давая понять, что с шутками покончено и откровениями тоже. Мазнул кистью по лежащему на столе переплету, вставил в него книжный блок. Все у него получалось ловко, красиво.

    — Как?

    Быстров подошел поближе. Портрет Ленина на обложке сиял свежей позолотой.
    
    Крячко, не таясь, зашагал в сторону гаража, в котором засел пьяный отморозок, вышел на открытое пространство, поднял руки и громко выкрикнул:

    — Эй, Мурмыгин! Ты мужик или трусливая дешевка? Вот он я, стою на самом виду. Можешь даже выстрелить в меня. Я тебя не боюсь. Чего спрятался за пацана? Позорище! Вот, гляди, мой смартфон. Я прямо сейчас выйду в интернет и буду вести репортаж на сайте «Вкус свободы», где пасется только крутая братва. Вот! Пошла связь, отлично! Парни, я полковник полиции Крячко. Веду свой репортаж с территории гаражных боксов, находящихся в поселке Тимофеево. Здесь отличился бывший сиделец Борька Мурмыгин. Он взял в заложники ребенка, мальчонку десяти лет, и прикрывается им, как последняя дешевка. Вот! Уже пошли отклики! Авторитет с погонялом Рольф пишет: «Если этот пес позорный попадет на зону, то я лично позабочусь о том, чтобы ему оторвали яйца!» Ага, еще один авторитетный гражданин с погонялом Морж пишет: «Дай координаты, полковник. Я сейчас лично приеду и порву этого петушару на куски голыми руками!»
    
    """,
    attributes: [
        .font: UIFont.systemFont(ofSize: 24)
    ])
    
    var textView: UITextView!
    var selectionRange: SelectionRange?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        ])
        
        textView.isEditable = false
        textView.isSelectable = false
        // TODO the following commented code will be useful for pagination
//        textView.isScrollEnabled = false
//        textView.textContainerInset = .zero
//        textView.textContainer.lineFragmentPadding = 0
        
        textView.attributedText = text
        // We must call the ensure layout method after we set the text so uiview will know how big the document is
        // this will avoid the issue of the user scrolling down and the input will register as if they didn't scroll
        textView.layoutManager.ensureLayout(forGlyphRange: NSRange(location: 0, length: textView.layoutManager.numberOfGlyphs))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        textView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if let currentSelectedRange = selectionRange {
            textView.textStorage.addAttribute(.foregroundColor, value: UIColor.black, range: currentSelectedRange.wordRange)
            textView.textStorage.removeAttribute(.underlineStyle, range: currentSelectedRange.sentenceRange)
            selectionRange = nil
        } else {
            // Get the users gesture input location, then the text view's layout manager can convert that cgrect to a character index. We will use that character index to handle the selection range. Once the selection range has been set we will highlight the word and underline the rest of the sentence.
            let layoutManager = textView.layoutManager
            var location = gesture.location(in: textView)
            location.x -= textView.textContainerInset.left
            location.y -= textView.textContainerInset.top
            let charIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            selectionRange = SelectionRange(text: text.string, characterIndex: charIndex)
            guard let currentRange = selectionRange else { return }
            textView.textStorage.addAttribute(.foregroundColor, value: UIColor.red, range: currentRange.wordRange)
            textView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: currentRange.sentenceRange)
            textView.textStorage.addAttribute(.underlineColor, value: UIColor.red, range: currentRange.sentenceRange)
        }
    }
}
