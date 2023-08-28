package com.example.apprunnerdemo;

import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Controller;

@Controller
public class Runner implements CommandLineRunner {

    private final BasicRepository basicRepository;

    public Runner(BasicRepository basicRepository) {
        this.basicRepository = basicRepository;
    }

    @Override
    public void run(String... args) throws Exception {
//        basicRepository.save(new PersonInfo("Ivan", 13));
//        basicRepository.save(new PersonInfo("Peter", 15));

//        var person = basicRepository.findByAge(15);
//        System.out.println(person);
    }
}
