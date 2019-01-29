import { createStore, combineReducers, applyMiddleware } from 'redux';
import { Profile } from './reducers/Profile';
import studentTaskList from './reducers/StudentTaskList';
import signUpSheetList from './reducers/SignUpSheetList';
import { Institutions } from './reducers/Institution';
import studentTaskView from './reducers/StudentTaskView';
import Grades from './reducers/Grade';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import authReducer from './reducers/Auth';
import studentTeamView from './reducers/StudentTeamView';
import responseReducer from './reducers/Response';
import submittedContent from './reducers/SubmittedContent';
import assignmentReviewData from './reducers/StudentReview';

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
            signUpSheetList: signUpSheetList,
            submittedContent: submittedContent,
            assignmentReviewData: assignmentReviewData,
            grades: Grades
        }),
        applyMiddleware(thunk, logger)
    );

    return store;
}