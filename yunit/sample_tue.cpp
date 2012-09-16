#include "test_unit_engine.h"
#include <stdio.h>
#include <string.h>
#include <string>

#define TEST(name) \
   static struct Test##_name : public BaseTest\
   {\
        typedef Test##_name Self;\
        Test##_name()\
        {\
            test_.self_ = this;\
            test_.test_ = &callAdapter<Self, &Self::test>;\
            testName_.assign(#name);\
        }\
        \
        void test(LoggerPtr logger)\
        {\
            try\
            {\
                realTest();\
            }\
            catch(...)\
            {\
                failure(logger, "unknown error in test");\
                return;\
            }\
            \
            success(logger);\
        }\
        void realTest();\
   } test##name;\
   static Test *aloneTest = &test##name.test_;\
   void Test##_name::realTest()

            //catch(std::exception &ex)
            //{
            //    failure(logger, ex.message());
            //}
            //catch(...)\ // !Attention! this statement will be cut in Release compile configuration

template<typename T, void (T::*method)(LoggerPtr)>
void callAdapter(void *t, LoggerPtr logger)
{
    (static_cast<T*>(t)->*method)(logger);
}

struct BaseTest
{
    typedef BaseTest Self;
    Test test_;
    
    BaseTest()
    {
        test_.self_ = this;
        test_.setUp_ = &callAdapter<Self, &Self::setUp>;
        //test_.test_ = &callAdapter<Self, &Self::test>;
        test_.tearDown_ = &callAdapter<Self, &Self::tearDown>;
        test_.name_ = &Self::name;
        test_.next_ = NULL;
    }
    
    virtual ~BaseTest()
    {
    }
    
    void setUp(LoggerPtr logger)
    {
        logger->success_(logger->self_);
    };
    
    void tearDown(LoggerPtr logger)
    {
        logger->success_(logger->self_);
    };
    
    const char* name() const
    {
        return testName_.c_str();
    }

    static const char* name(const void *self)
    {
        return ((const Self*)self)->name();
    }
    
    std::string testName_;
};

const char** testContainerExtensions()
{
    static const char* supportedExts[] = {"t.so", NULL};
    return supportedExts;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TEST(emptyTest)
{
}


Test* loadTestContainer(const char *path)
{
    return aloneTest;
}

