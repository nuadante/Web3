// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.7;

 contract Todos {

    struct Todo {  
        string text; 
        bool completed;
    }

    Todo[] public todos;  

      event TaskCreated(
    string content,
    bool completed
  );

  event TaskCompleted(
    uint id,
    bool completed
  );

    event TaskUpdated(
    uint id,
    string updated
  );


    function createTask(string memory _text) external {  
        todos.push(Todo(_text, false));
        emit TaskCreated(_text, false);
    }

    function getTask(uint _index) external view returns (string memory text, bool completed) {  
        return (todos[_index].text, todos[_index].completed);
    }

    function updateTask(uint _index, string memory _text) external {  
        todos[_index].text = _text;
        emit TaskUpdated(_index,_text)
    }

    function completeTask(uint _index) external {  
        todos[_index].completed = !todos[_index].completed;
        emit TaskCompleted(_index, todos[_index].completed);
    }
}