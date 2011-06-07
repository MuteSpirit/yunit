if(WIN32)
    install(DIRECTORY .
              DESTINATION 5.1/lua
              FILES_MATCHING 
                PATTERN "*.lua" 
                PATTERN "*.t.lua" EXCLUDE
                PATTERN "migrate_*.lua" EXCLUDE)
else(WIN32)
    install(DIRECTORY .
              DESTINATION lib/lua/5.1/lua
              FILES_MATCHING PATTERN "*.lua")
endif(WIN32)
