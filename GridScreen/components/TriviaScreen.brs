' entry point of TriviaScreen
' Note that we need to import this file in TriviaScreen.xml using relative path.
sub Init()
    totalQuestions = 5
    m.gameOver = false
    m.top.findNode("background").color = "0x662D91"
    m.labelList = m.top.findNode("optionLabelList")
    m.index = 0
    ' todo get random unique questions
    'm.questionList = GetRandomUniqueArray(totalQuestions)
    SetupQuestionList()
    'm.questionList = [1,0,2,3,4]
    setupQuestion(m.questionList[m.index])
    m.labelList.observeField("itemSelected", "answerSelected")
    m.corrects = 0
end sub



function SetupQuestion(QuestionNumber as integer)
    m.top.findNode("background").color = "0x662D91"
    questionLabel = m.top.findNode("questionLabel")
    questionsArray = ParseJson(ReadAsciiFile("pkg:/images/questions.json"))
    ' Create a ContentNode to hold the data for the list.
    content = createObject("roSGNode", "ContentNode")
    ' Populate the list with our JSON question data.
    listItems = [questionsArray[QuestionNumber].Answer, questionsArray[QuestionNumber].Distractor1, questionsArray[QuestionNumber].Distractor2]
    ' Shuffle the list items to randomize their order.
    shuffleList(listItems)

    ' Set the correct answer to check later
    m.correctAnswer = questionsArray[QuestionNumber].Answer

    ' Loop through the data and create a child node for each item.
    for each listItem in listItems
        childContent = createObject("roSGNode", "ContentNode")
        childContent.title = listItem
        content.appendChild(childContent)
    end for

    m.labelList.content = content
  
    questionLabel.text = m.index.toStr() + ": " + questionsArray[QuestionNumber].Question
    m.top.findNode("optionLabelList").setFocus(true) 
end function


function AnswerSelected()
    selected = m.labelList.content.getChild(m.labelList.itemSelected).title
    if selected = m.correctAnswer
        m.corrects = m.corrects + 1
        m.top.findNode("background").color = "0x00FF00" ' Change background to green
    else
        m.top.findNode("background").color = "0xFF0000" ' Change background to red
    end if
    

    ' Move to the next question or end the game if all questions are done
    if m.index < 4
        m.index = m.index + 1
        setupQuestion(m.questionList[m.index])
    else
        m.top.findNode("questionLabel").text = "Game Over!"
        GameOver()
    end if
end function

Function SetUpQuestionList() as Object
    m.questionsArray = ParseJson(ReadAsciiFile("pkg:/images/questions.json"))
    length = m.questionsArray.Count()
    m.questionList = []
    n = 0
    while m.questionList.Count() < 5
        n = Int(Rnd(0) * length)
        if m.questionList.Lookup(n) = invalid
            m.questionList.Push(n)
        end if
    end while
    m.top.findNode("questionLabel").text = "Questions: " + m.questionList.ToStr()
End Function

Function GameOver()
    gameOverScreen = m.top.findNode("scoreGroup")
    gameOverScreen.visible = true
    scoreLabel = m.top.findNode("scoreLabel")
    scoreLabel.text = "Game Over! You got " + m.corrects.ToStr() + " out of 5 correct."
    m.gameOver = true
End Function

Function OnKeyEvent(key as String, press as Boolean) as Boolean
    if m.gameOver = true
        if key = "replay" and press = true
            ' Restart the game
            m.gameOver = false
            m.corrects = 0
            m.index = 0
            gameOverScreen = m.top.findNode("scoreGroup")
            gameOverScreen.visible = false
            setupQuestion(m.questionList[m.index])
            return true
        end if
    end if
    return false
End Function

Function ShuffleList(items As Object) As Void
  ' Generate a random number between 0 and 2 for the first position
  randomIndex = Rnd(3) - 1

  ' Swap the first item with the item at the random index
  temp = items[0]
  items[0] = items[randomIndex]
  items[randomIndex] = temp

  ' Now, shuffle the remaining two items (at indices 1 and 2)
  ' We can do this by swapping them with a 50% chance
  if Rnd(2) = 1
    temp = items[1]
    items[1] = items[2]
    items[2] = temp
  end if
End Function