pragma solidity ^0.4.18;

import { State } from "./State.sol";
import { ProcessRunner } from "./ProcessRunner.sol";
import { RBAC } from "../utils/Roles/RBAC.sol";

contract StateMachineBuilder is RBAC, ProcessRunner {

  struct Transition {
    string authorizedRole;
    bool networked;
  }

  using State for State.Machine;

  mapping(bytes32 => State.Machine) stateMachines;

  mapping(bytes32 => Transition) labels;

  event LabelAdded(bytes32 label);
  event StateTransitionAdded(bytes32 machineId, bytes32 fromState, bytes32 toState, bytes32 label, address user);
  event StateTransitionRemoved(bytes32 machineId, bytes32 fromState, bytes32 toState, address user);
  event StateTransitionPerformed(bytes32 machineId, bytes32 processId, bytes32 fromState, bytes32 toState, address user);

  function addLabel(bytes32 label, string role, bool _networked) onlyAdmin {
    labels[label].authorizedRole = role;
    labels[label].networked = _networked;
    LabelAdded(label);
  }

  function addStateTransition(bytes32 machineId, bytes32 fromState, bytes32 toState, bytes32 label) onlyAdmin {
    stateMachines[machineId].addTransition(fromState, toState, label);
    StateTransitionAdded(machineId, fromState, toState, label, msg.sender);
  }

  function removeStateTransition(bytes32 machineId, bytes32 fromState, bytes32 toState) onlyAdmin {
    stateMachines[machineId].removeTransition(fromState, toState);
    StateTransitionRemoved(machineId, fromState, toState, msg.sender);
  }

  function performStateTransition(bytes32 machineId, bytes32 processId, bytes32 toState) returns (bool) {
    bytes32 fromState = stateMachines[machineId].processes[processId];

    //Check that caller is authorized to make this state change
    checkRole(msg.sender, labels[stateMachines[machineId].transitionGraph[fromState][toState]].authorizedRole);

    //Check that the transition does not need a network call
    require(!labels[stateMachines[machineId].transitionGraph[fromState][toState]].networked);

    //Perform transition on state machine
    require(stateMachines[machineId].performTransition(processId, toState));
    StateTransitionPerformed(machineId, processId, fromState, toState, msg.sender);
    return true;
  }

  function performNetworkedStateTransition(bytes32 machineId, bytes32 processId, bytes32 toState, bytes32 targetMachineId, bytes32 targetProcessId, bytes32 targetToState, address target) {
    bytes32 fromState = stateMachines[machineId].processes[processId];

    //Check that caller is authorized to make this state change
    checkRole(msg.sender, labels[stateMachines[machineId].transitionGraph[fromState][toState]].authorizedRole);

    //Check that the transition requires an additional network call
    require(labels[stateMachines[machineId].transitionGraph[fromState][toState]].networked);

    //Perform transition on home state machine
    require(stateMachines[machineId].performTransition(processId, toState));

    //Perform transition on target state machine
    require(ProcessRunner(target).performStateTransition(targetMachineId, targetProcessId, targetToState));
    StateTransitionPerformed(machineId, processId, fromState, toState, msg.sender);
  }

  function isValidStateTransition(bytes32 machineId, bytes32 fromState, bytes32 toState) view returns (bool) {
    return stateMachines[machineId].isValidTransition(fromState, toState);
  }

  function getProcessState(bytes32 machineId, bytes32 processId) view returns (bytes32) {
    return stateMachines[machineId].processes[processId];
  }

}
