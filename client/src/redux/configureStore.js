import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Profile } from './reducers/Profile';
import studentTaskList from './reducers/StudentTaskList';
import { Institutions } from './reducers/Institution';
import studentTaskView from './reducers/StudentTaskView';
import Grades from './reducers/Grade';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import authReducer from './reducers/Auth';
import studentTeamView from './reducers/StudentTeamView';
import responseReducer from './reducers/Response';

export const ConfigureStore = () => {
    const store = createStore(
        combineReducers({
            profile: Profile,
            studentTaskList: studentTaskList,
            institutions: Institutions,
            studentTaskView:  studentTaskView,
            auth: authReducer,
            studentTeamView: studentTeamView,
            responseReducer: responseReducer,
            grades: Grades
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
}