' entry point of TriviaScreen
sub Init()
    m.labelList = m.top.findNode("optionLabelList")
    m.timer = m.top.findNode("timer")
    m.labelList.observeField("itemSelected", "AnswerSelected")
    m.timer.observeField("fire", "StartNextQuestion")
    SetupGame()
end sub

function SetupGame() 
    m.gameOver = false
    m.top.findNode("background").color = "0x662D91"
    m.top.findNode("scoreGroup").visible = false
    m.index = 0
    m.corrects = 0
    SetupQuestionList()
    setupQuestion(m.questionList[m.index])
end function

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
  
    questionLabel.text = (m.index + 1).toStr() + ") " + questionsArray[QuestionNumber].Question
    m.top.findNode("optionLabelList").setFocus(true) 
end function

function AnswerSelected()
    selected = m.labelList.content.getChild(m.labelList.itemSelected).title
    if selected = m.correctAnswer
        m.corrects = m.corrects + 1
        m.top.findNode("background").color = "0x2a9c19" ' Change background to green
    else
        m.top.findNode("background").color = "0xdb4242" ' Change background to red
    end if

    m.index = m.index + 1
    m.timer.control = "start" ' Start the timer to wait before showing the next question   
end function

function StartNextQuestion()
    ' Timer fired, reset background color and start next question or game over
    m.top.findNode("background").color = "0x662D91"
    if m.index < 5  
        setupQuestion(m.questionList[m.index])
    else
        GameOver()
    end if
end function

function SetUpQuestionList() as Object
    m.questionsArray = ParseJson(ReadAsciiFile("pkg:/images/questions.json"))
    length = m.questionsArray.Count()
    n = 0
    m.questionList = []
    while m.questionList.Count() < 5
        n = Int(Rnd(length) - 1)
        if ArrayContains(m.questionList, n) = false
            m.questionList.Push(n)
        end if
    end while
end function

function ArrayContains(arr as Object, value as Integer) as Boolean
    for each item in arr
        if item = value
            return true
        end if
    end for
    return false
end function

function GameOver()
    gameOverScreen = m.top.findNode("scoreGroup")
    gameOverScreen.visible = true
    scoreLabel = m.top.findNode("scoreLabel")
    if m.corrects = 5
        scoreLabel.text = "Congratulations! You got all 5 questions correct!"
    else 
        scoreLabel.text = "Game Over! You got " + m.corrects.ToStr() + " out of 5 correct."
    end if
    m.gameOver = true
end function

function OnKeyEvent(key as String, press as Boolean) as Boolean
    if m.gameOver = true
        if key = "replay" and press = true
            ' Restart the game
            SetupGame()
            return true
        end if
    end if
    return false
end function

function ShuffleList(items As Object) As Void
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
end function